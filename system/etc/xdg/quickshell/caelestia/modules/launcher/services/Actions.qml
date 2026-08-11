pragma Singleton

import ".."
import QtQuick
import Quickshell
import Caelestia.Config
import Caelestia.Services
import qs.services
import qs.utils

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(GlobalConfig.launcher.actionPrefix.length);
    }

    function actionRank(action: var): int {
        const name = String(action.name ?? "").toLowerCase();
        const order = {
            "calculator": 10, "execute command": 11, "clipboard": 12,
            "scheme": 20, "wallpaper": 21, "variant": 22, "random": 23,
            "light": 24, "dark": 25, "unlock screen": 26,
            "change font": 27, "change theme": 28,
            "lock": 30, "sleep": 31, "settings": 32,
            "update system": 60
        };
        if (order[name] !== undefined) return order[name];
        if (name === "install") return 40;
        if (name === "uninstall") return 50;
        return 55;
    }

    function orderedActions(actions: var): var {
        return actions.map((action, index) => ({ action, index })).sort((a, b) => {
            const rank = actionRank(a.action) - actionRank(b.action);
            return rank !== 0 ? rank : a.index - b.index;
        }).map(item => item.action);
    }

    list: variants.instances.filter(action => action.category.length === 0)
    useFuzzy: GlobalConfig.launcher.useFuzzy.actions

    function categoryQuery(search: string, category: string): var {
        const route = `${GlobalConfig.launcher.actionPrefix}${category}`;
        const suffix = search.startsWith(route) ? search.slice(route.length).trim().toLowerCase() : "";
        return variants.instances.filter(action => action.category === category).filter(action => !suffix || action.name.toLowerCase().includes(suffix) || action.desc.toLowerCase().includes(suffix));
    }

    Variants {
        id: variants

        model: root.orderedActions(GlobalConfig.launcher.actions.concat([
            { name: qsTr("Install"), description: qsTr("Packages and web apps"), icon: "download", command: ["autocomplete", "install"] },
            { name: qsTr("Uninstall"), description: qsTr("Packages and web apps"), icon: "delete", command: ["autocomplete", "uninstall"] },
            { category: "install", name: qsTr("AUR"), description: qsTr("Search the AUR and select packages"), icon: "deployed_code", command: ["autocomplete", "aur"] },
            { category: "install", name: qsTr("Brew"), description: qsTr("Search Homebrew formulae and select packages"), icon: "download", command: ["autocomplete", "brew"] },
            { category: "install", name: qsTr("Flatpak"), description: qsTr("Search Flathub and select applications"), icon: "download", command: ["autocomplete", "flatpak"] },
            { category: "install", name: qsTr("Package"), description: qsTr("Search the Arch repositories and select packages"), icon: "download", command: ["autocomplete", "package"] },
            { category: "install", name: qsTr("Web app"), description: qsTr("Create a desktop web application"), icon: "web", command: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-webapp-install"] },
            { category: "uninstall", name: qsTr("AUR"), description: qsTr("Search installed AUR packages"), icon: "delete", command: ["autocomplete", "remove-aur"] },
            { category: "uninstall", name: qsTr("Brew"), description: qsTr("Search installed Homebrew formulae and casks"), icon: "delete", command: ["autocomplete", "remove-brew"] },
            { category: "uninstall", name: qsTr("Flatpak"), description: qsTr("Search installed Flatpak applications"), icon: "delete", command: ["autocomplete", "remove-flatpak"] },
            { category: "uninstall", name: qsTr("Package"), description: qsTr("Search installed repository packages"), icon: "delete", command: ["autocomplete", "remove"] },
            { category: "uninstall", name: qsTr("Web app"), description: qsTr("Search installed Omarchy web applications"), icon: "delete", command: ["autocomplete", "remove-webapp"] },
            { name: qsTr("Execute command"), description: qsTr("Open a tiled terminal with a command ready to edit"), icon: "terminal", command: ["autocomplete", "exec"] },
            { name: qsTr("Clipboard"), description: qsTr("Search and paste clipboard history"), icon: "content_paste", command: ["autocomplete", "clipboard"] },
            { name: qsTr("Emoji"), description: qsTr("Search emoji, then copy and paste the selection"), icon: "emoji_emotions", command: ["autocomplete", "emoji"] },
            { name: qsTr("Key bindings"), description: qsTr("Browse Caelestia, system, and application shortcuts"), icon: "keyboard", command: ["autocomplete", "keybinds"] },
            { name: qsTr("Unlock screen"), description: qsTr("Choose the boot and login unlock artwork"), icon: "lock_open", command: ["autocomplete", "unlock"] },
            { name: qsTr("Change font"), description: qsTr("Choose the desktop and terminal font"), icon: "font_download", command: ["autocomplete", "font"] },
            { name: qsTr("Change theme"), description: qsTr("Choose an installed Omarchy colour theme"), icon: "palette", command: [Quickshell.env("HOME") + "/.local/bin/omarchy-quattro-selector", "theme"] },
            { name: qsTr("Update system"), description: qsTr("Update Arch, AUR packages, and Omarchy"), icon: "system_update", command: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"] }
        ]).filter(a => (a.enabled ?? true) && (GlobalConfig.launcher.enableDangerousActions || !(a.dangerous ?? false))))

        Action {}
    }

    component Action: QtObject {
        required property var modelData
        readonly property string name: modelData.name ?? qsTr("Unnamed")
        readonly property string desc: modelData.description ?? qsTr("No description")
        readonly property string icon: modelData.icon ?? "help_outline"
        readonly property string category: modelData.category ?? ""
        readonly property list<string> command: modelData.command ?? []
        readonly property bool enabled: modelData.enabled ?? true
        readonly property bool dangerous: modelData.dangerous ?? false

        function onClicked(list: AppList): void {
            if (command.length === 0)
                return;

            if (command[0] === "autocomplete" && command.length > 1) {
                list.search.text = `${GlobalConfig.launcher.actionPrefix}${command[1]} `;
            } else if (command[0] === "setMode" && command.length > 1) {
                list.screenState.launcher = false;
                Colours.setMode(command[1]);
            } else {
                list.screenState.launcher = false;
                if (!SessionManager.exec(command))
                    Quickshell.execDetached(command);
            }
        }
    }
}

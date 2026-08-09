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
        if (name.startsWith("install ")) return 40;
        if (name.startsWith("remove ")) return 50;
        return 55;
    }

    function orderedActions(actions: var): var {
        return actions.map((action, index) => ({ action, index })).sort((a, b) => {
            const rank = actionRank(a.action) - actionRank(b.action);
            return rank !== 0 ? rank : a.index - b.index;
        }).map(item => item.action);
    }

    list: variants.instances
    useFuzzy: GlobalConfig.launcher.useFuzzy.actions

    Variants {
        id: variants

        model: root.orderedActions(GlobalConfig.launcher.actions.concat([
            { name: qsTr("Install package"), description: qsTr("Search the Arch repositories and select packages"), icon: "download", command: ["autocomplete", "package"] },
            { name: qsTr("Install AUR package"), description: qsTr("Search the AUR and select packages"), icon: "deployed_code", command: ["autocomplete", "aur"] },
            { name: qsTr("Install Flatpak package"), description: qsTr("Search Flathub and select applications"), icon: "download", command: ["autocomplete", "flatpak"] },
            { name: qsTr("Install Brew package"), description: qsTr("Search Homebrew formulae and select packages"), icon: "download", command: ["autocomplete", "brew"] },
            { name: qsTr("Remove package"), description: qsTr("Search installed repository and AUR packages"), icon: "delete", command: ["autocomplete", "remove"] },
            { name: qsTr("Remove Flatpak package"), description: qsTr("Search installed Flatpak applications"), icon: "delete", command: ["autocomplete", "remove-flatpak"] },
            { name: qsTr("Remove Brew package"), description: qsTr("Search installed Homebrew formulae and casks"), icon: "delete", command: ["autocomplete", "remove-brew"] },
            { name: qsTr("Remove web app"), description: qsTr("Search installed Omarchy web applications"), icon: "delete", command: ["autocomplete", "remove-webapp"] },
            { name: qsTr("Execute command"), description: qsTr("Open a tiled terminal with a command ready to edit"), icon: "terminal", command: ["autocomplete", "exec"] },
            { name: qsTr("Clipboard"), description: qsTr("Search and paste clipboard history"), icon: "content_paste", command: ["autocomplete", "clipboard"] },
            { name: qsTr("Emoji"), description: qsTr("Search emoji, then copy and paste the selection"), icon: "emoji_emotions", command: ["autocomplete", "emoji"] },
            { name: qsTr("Key bindings"), description: qsTr("Browse Caelestia, system, and application shortcuts"), icon: "keyboard", command: ["autocomplete", "keybinds"] },
            { name: qsTr("Unlock screen"), description: qsTr("Choose the boot and login unlock artwork"), icon: "lock_open", command: ["autocomplete", "unlock"] },
            { name: qsTr("Change font"), description: qsTr("Choose the desktop and terminal font"), icon: "font_download", command: ["autocomplete", "font"] },
            { name: qsTr("Change theme"), description: qsTr("Choose an installed Omarchy colour theme"), icon: "palette", command: [Quickshell.env("HOME") + "/.local/bin/omarchy-quattro-selector", "theme"] },
            { name: qsTr("Install web app"), description: qsTr("Create a desktop web application"), icon: "web", command: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-webapp-install"] },
            { name: qsTr("Update system"), description: qsTr("Update Arch, AUR packages, and Omarchy"), icon: "system_update", command: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"] }
        ]).filter(a => (a.enabled ?? true) && (GlobalConfig.launcher.enableDangerousActions || !(a.dangerous ?? false))))

        Action {}
    }

    component Action: QtObject {
        required property var modelData
        readonly property string name: modelData.name ?? qsTr("Unnamed")
        readonly property string desc: modelData.description ?? qsTr("No description")
        readonly property string icon: modelData.icon ?? "help_outline"
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

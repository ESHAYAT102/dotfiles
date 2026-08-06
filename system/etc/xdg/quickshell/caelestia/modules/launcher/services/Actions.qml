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

    list: variants.instances
    useFuzzy: GlobalConfig.launcher.useFuzzy.actions

    Variants {
        id: variants

        model: GlobalConfig.launcher.actions.concat([
            { name: qsTr("Install package"), description: qsTr("Search the Arch repositories and select packages"), icon: "download", command: ["autocomplete", "package"] },
            { name: qsTr("Install AUR package"), description: qsTr("Search the AUR and select packages"), icon: "deployed_code", command: ["autocomplete", "aur"] },
            { name: qsTr("Remove package"), description: qsTr("Search installed repository and AUR packages"), icon: "delete", command: ["autocomplete", "remove"] },
            { name: qsTr("Unlock screen"), description: qsTr("Choose the boot and login unlock artwork"), icon: "lock_open", command: ["autocomplete", "unlock"] },
            { name: qsTr("Change font"), description: qsTr("Choose the desktop and terminal font"), icon: "font_download", command: ["omarchy-menu", "toggle", "style.font"] },
            { name: qsTr("Change theme"), description: qsTr("Choose an installed Omarchy colour theme"), icon: "palette", command: ["omarchy-menu", "toggle", "style.theme"] },
            { name: qsTr("Install web app"), description: qsTr("Create a desktop web application"), icon: "web", command: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-webapp-install"] },
            { name: qsTr("Update system"), description: qsTr("Update Arch, AUR packages, and Omarchy"), icon: "system_update", command: ["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"] }
        ]).filter(a => (a.enabled ?? true) && (GlobalConfig.launcher.enableDangerousActions || !(a.dangerous ?? false)))

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

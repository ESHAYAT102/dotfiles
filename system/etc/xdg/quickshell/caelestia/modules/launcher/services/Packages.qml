pragma Singleton

import ".."
import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config

Singleton {
    id: root

    property string sourceType: "repo"
    property string pendingQuery: ""
    property string loadedQuery: ""
    property var names: []
    property var selected: ({})
    readonly property list<QtObject> entries: variants.instances

    function reset(type: string): void {
        sourceType = type;
        pendingQuery = "";
        loadedQuery = "";
        names = [];
        selected = ({});
    }

    function query(text: string, type: string): var {
        const command = type === "aur" ? "aur" : type === "remove" ? "remove" : "package";
        const prefix = `${GlobalConfig.launcher.actionPrefix}${command} `;
        const term = text.slice(prefix.length).trim();
        if (type !== sourceType || term !== pendingQuery) {
            Qt.callLater(() => {
                if (type !== root.sourceType) root.reset(type);
                root.pendingQuery = term;
                debounce.restart();
            });
        }
        return [...entries];
    }

    function toggle(name: string): void {
        const next = Object.assign({}, selected);
        if (next[name]) delete next[name]; else next[name] = true;
        selected = next;
    }

    function execute(name: string, list: AppList): void {
        const chosen = Object.keys(selected);
        if (!chosen.includes(name)) chosen.push(name);
        if (!chosen.length) return;
        list.screenState.launcher = false;
        const safe = chosen.filter(n => /^[A-Za-z0-9@._+:-]+$/.test(n));
        const cmd = sourceType === "aur"
            ? `yay -S --needed -- ${safe.join(" ")}`
            : sourceType === "remove"
                ? `sudo pacman -Rns -- ${safe.join(" ")}`
                : `sudo pacman -S --needed -- ${safe.join(" ")}`;
        Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", cmd]);
        selected = ({});
    }

    Variants {
        id: variants
        model: root.names
        PackageEntry {}
    }

    component PackageEntry: QtObject {
        required property string modelData
        readonly property string name: modelData
        readonly property string desc: root.sourceType === "aur" ? qsTr("Arch User Repository") : root.sourceType === "remove" ? qsTr("Installed package") : qsTr("Official Arch repository")
        readonly property string icon: root.selected[name] ? "check_box" : "check_box_outline_blank"
        readonly property bool isSelected: root.selected[name] ?? false
        function toggleSelected(): void { root.toggle(name); }
        function onClicked(list: AppList): void { root.execute(name, list); }
    }

    Timer {
        id: debounce
        interval: 250
        onTriggered: {
            if (root.pendingQuery.length < 2) {
                root.names = [];
                return;
            }
            loader.command = [Quickshell.env("HOME") + "/.local/bin/caelestia-package-search", root.sourceType, root.pendingQuery];
            loader.running = false;
            loader.running = true;
        }
    }

    Process {
        id: loader
        stdout: StdioCollector {
            onStreamFinished: {
                root.loadedQuery = root.pendingQuery;
                root.names = text.trim().split("\n").filter(n => n.length > 0);
            }
        }
    }
}

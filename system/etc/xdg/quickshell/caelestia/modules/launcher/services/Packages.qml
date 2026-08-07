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
    property string loadedQuery: "\u0000"
    property var names: []
    property var selected: ({})
    readonly property list<QtObject> entries: variants.instances

    function prefixFor(type: string): string {
        const command = type === "repo" ? "package" : type;
        return `${GlobalConfig.launcher.actionPrefix}${command} `;
    }

    function shellQuote(value: string): string {
        return "'" + value.replace(/'/g, "'\\''") + "'";
    }

    function reset(type: string): void {
        sourceType = type;
        pendingQuery = "";
        loadedQuery = "\u0000";
        names = [];
        selected = ({});
    }

    function query(text: string, type: string): var {
        const prefix = prefixFor(type);
        const term = text.slice(prefix.length).trim();
        if (type !== sourceType || term !== pendingQuery || term !== loadedQuery) {
            Qt.callLater(() => {
                if (type !== root.sourceType) root.reset(type);
                root.pendingQuery = term;
                root.loadedQuery = term;
                if (type === "exec") {
                    root.names = term.length ? [term] : [];
                } else {
                    debounce.restart();
                }
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
        if (sourceType === "exec") {
            if (!name.trim().length) return;
            list.screenState.launcher = false;
            Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/caelestia-prefill-terminal", name]);
            return;
        }
        if (sourceType === "emoji") {
            if (!name.length) return;
            list.screenState.launcher = false;
            Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/caelestia-emoji-insert", name]);
            return;
        }

        const chosen = Object.keys(selected);
        if (!chosen.includes(name)) chosen.push(name);
        if (!chosen.length) return;
        list.screenState.launcher = false;
        const safe = chosen.filter(n => /^[A-Za-z0-9@._+:/-]+$/.test(n));
        const cmd = sourceType === "aur"
            ? `yay -S --needed -- ${safe.join(" ")}`
            : sourceType === "remove"
                ? `sudo pacman -Rns -- ${safe.join(" ")}`
                : sourceType === "remove-flatpak"
                    ? `flatpak uninstall --system -y -- ${safe.join(" ")}`
                    : sourceType === "remove-brew"
                        ? `/home/linuxbrew/.linuxbrew/bin/brew uninstall -- ${safe.map(shellQuote).join(" ")}`
                : sourceType === "flatpak"
                    ? `flatpak install --system -y flathub -- ${safe.join(" ")}`
                    : sourceType === "brew"
                        ? `/home/linuxbrew/.linuxbrew/bin/brew install -- ${safe.map(shellQuote).join(" ")}`
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
        readonly property var fields: modelData.split("\t")
        readonly property string name: fields[0]
        readonly property string desc: root.sourceType === "aur" ? qsTr("Arch User Repository")
            : root.sourceType === "remove" ? qsTr("Installed package")
            : root.sourceType === "remove-flatpak" ? qsTr("Installed Flatpak application")
            : root.sourceType === "remove-brew" ? qsTr("Installed Homebrew package")
            : root.sourceType === "flatpak" ? qsTr("Flathub")
            : root.sourceType === "brew" ? qsTr("Homebrew formula")
            : root.sourceType === "exec" ? qsTr("Open in a tiled terminal without running it")
            : root.sourceType === "keybinds" ? (fields[1] ?? qsTr("Keyboard shortcut"))
            : root.sourceType === "emoji" ? (fields[1] ?? qsTr("Emoji"))
            : qsTr("Official Arch repository")
        readonly property string icon: root.sourceType === "exec" ? "terminal" : root.sourceType === "keybinds" ? "keyboard" : root.sourceType === "emoji" ? "emoji_emotions" : root.selected[name] ? "check_box" : "check_box_outline_blank"
        readonly property bool isSelected: root.selected[name] ?? false
        function toggleSelected(): void { if (root.sourceType !== "emoji") root.toggle(name); }
        function onClicked(list: AppList): void { if (root.sourceType !== "keybinds") root.execute(name, list); }
    }

    Timer {
        id: debounce
        interval: 250
        onTriggered: {
            if (root.sourceType === "exec" || (!["keybinds", "emoji"].includes(root.sourceType) && root.pendingQuery.length < 2)) {
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

pragma Singleton

import ".."
import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.utils

Searcher {
    id: root

    property var entries: []

    function transformSearch(search: string): string {
        return search.slice(`${GlobalConfig.launcher.actionPrefix}clipboard `.length);
    }

    function reload(): void {
        loader.running = false;
        loader.running = true;
    }

    function clear(): void {
        Quickshell.execDetached(["cliphist", "wipe"]);
        reloadTimer.restart();
    }

    list: variants.instances
    useFuzzy: GlobalConfig.launcher.useFuzzy.actions
    keys: ["name", "desc"]
    weights: [0.8, 0.2]

    Variants {
        id: variants
        model: root.entries
        ClipboardEntry {}
    }

    Process {
        id: loader
        command: [Quickshell.env("HOME") + "/.local/bin/caelestia-clipboard-list"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.trim().split("\n").filter(line => line.length > 0).map(line => {
                    const tab = line.indexOf("\t");
                    const id = Number(tab < 0 ? line : line.slice(0, tab));
                    const value = tab < 0 ? line : line.slice(tab + 1);
                    return {
                        id: Number.isFinite(id) ? id : 0,
                        value
                    };
                }).filter(entry => entry.id > 0);
            }
        }
    }

    Timer {
        id: reloadTimer
        interval: 200
        onTriggered: root.reload()
    }

    component ClipboardEntry: QtObject {
        required property var modelData
        readonly property int entryId: modelData.id
        readonly property string value: modelData.value
        readonly property bool isImage: value.startsWith("[[ binary data ")
        readonly property string name: isImage ? qsTr("Image") : value.split("\\n")[0] || qsTr("Clipboard entry")
        readonly property string desc: isImage ? value.slice(3, -3).replace("binary data ", "").replace(" png ", " · PNG · ").replace(" jpg ", " · JPG · ").replace(" jpeg ", " · JPEG · ").replace(" webp ", " · WebP · ") : qsTr("Clipboard history · #%1").arg(entryId)
        readonly property string icon: isImage ? "image" : "content_paste"
        readonly property string previewPath: `${Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache"}/caelestia/clipboard/${entryId}.img`

        function onClicked(list: AppList): void {
            list.screenState.launcher = false;
            Quickshell.execDetached(["sh", "-c", `cliphist decode ${entryId} | wl-copy`]);
        }

        function remove(): void {
            Quickshell.execDetached(["sh", "-c", `printf '%s\\n' ${entryId} | cliphist delete`]);
            reloadTimer.restart();
        }
    }
}

import "items"
import QtQuick
import Qt.labs.folderlistmodel
import Caelestia.Config
import qs.components.controls

PathView {
    id: root
    required property SearchBar search
    required property var screenState
    readonly property int itemWidth: Tokens.sizes.launcher.wallpaperWidth * 0.8 + Tokens.padding.medium * 2
    readonly property int numItems: Math.max(1, Math.min(5, count % 2 === 0 ? count - 1 : count))
    model: FolderListModel {
        folder: "file:///home/esh/.local/share/omarchy/themes"
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }
    implicitWidth: Math.min(numItems, count) * itemWidth
    pathItemCount: numItems
    cacheItemCount: 4
    snapMode: PathView.SnapToItem
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange
    delegate: UnlockItem {
        required property string fileName
        required property url fileUrl
        themeName: fileName
        themePath: fileUrl.toString().replace("file://", "")
        screenState: root.screenState
    }
    path: Path {
        startY: root.height / 2
        PathAttribute { name: "z"; value: 0 }
        PathLine { x: root.width / 2; relativeY: 0 }
        PathAttribute { name: "z"; value: 1 }
        PathLine { x: root.width; relativeY: 0 }
    }
}

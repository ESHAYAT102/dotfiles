import QtQuick
import Quickshell

Item {
  id: root

  property var manifest: null
  property var shell: null
  readonly property var clipboard: loader.item
  readonly property bool opened: clipboard ? clipboard.opened : false

  function open(payloadJson) { if (clipboard) clipboard.open(payloadJson || "{}") }
  function close() { if (clipboard) clipboard.close() }
  function toggle() { if (clipboard) clipboard.toggle() }

  Loader {
    id: loader
    anchors.fill: parent
    source: "file:///usr/share/omarchy/shell/plugins/clipboard/Clipboard.qml"
  }

  Shortcut {
    sequence: "Ctrl+D"
    context: Qt.ApplicationShortcut
    enabled: root.opened
    onActivated: {
      if (root.clipboard && root.clipboard.history.length > 0) {
        root.clipboard.removeDisplayIndex(0)
      }
    }
  }

  Shortcut {
    sequence: "Ctrl+Shift+D"
    context: Qt.ApplicationShortcut
    enabled: root.opened
    onActivated: {
      if (root.clipboard && root.clipboard.history.length > 0) {
        root.clipboard.confirmClearHistory()
      }
    }
  }
}

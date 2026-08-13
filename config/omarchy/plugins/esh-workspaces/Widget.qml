import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "esh.workspaces"

  function workspace(id) {
    const values = Hyprland.workspaces.values
    for (let i = 0; i < values.length; i++) if (values[i].id === id) return values[i]
    return null
  }
  function focus(id) {
    if (bar) bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  RowLayout {
    id: row
    anchors.fill: parent
    spacing: 0

    Repeater {
      model: 5
      WidgetButton {
        required property int index
        readonly property int workspaceId: index + 1
        readonly property var ws: root.workspace(workspaceId)
        readonly property bool occupied: ws && ws.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace?.id === workspaceId
        bar: root.bar
        text: focused ? "󰮯" : (occupied ? "󰊠" : "●")
        fontSize: Style.font.title
        opacity: occupied ? 1 : 0.45
        fixedWidth: Style.space(19)
        fixedHeight: root.barSize
        horizontalMargin: 0
        onPressed: root.focus(workspaceId)
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    Quickshell.execDetached([
      "hyprctl",
      "eval",
      "hl.dispatch(hl.dsp.focus({ workspace = " + Number(id) + " }))"
    ])
  }

  function handleModuleClick(button, localX, localY) {
    if (button !== Qt.LeftButton) return false

    var point = grid.mapFromItem(root, localX, localY)
    for (var i = 0; i < workspaceRepeater.count; i++) {
      var item = workspaceRepeater.itemAt(i)
      if (!item || !item.visible) continue

      if (point.x >= item.x && point.x <= item.x + item.width &&
          point.y >= item.y && point.y <= item.y + item.height) {
        focusWorkspace(item.modelData)
        return true
      }
    }

    return false
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      id: workspaceRepeater
      model: root.workspaceIds()

      BarIconButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: focused ? "󰮯" : (occupied ? "󰊠" : "")
        fontSize: focused || occupied ? 14 : 10
        opticalVerticalOffset: focused ? 1 : 0.5
        opacity: occupied ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function(button) {
          if (button === Qt.LeftButton) root.focusWorkspace(modelData)
        }
      }
    }
  }
}

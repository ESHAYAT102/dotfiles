import QtQuick
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.notifications"

  property int notificationCount: 0
  property bool dnd: false

  readonly property string icon: dnd ? "󰂛" : (notificationCount > 0 ? "󱅫" : "󰂚")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!countProbe.running) countProbe.running = true
    if (!dndProbe.running) dndProbe.running = true
  }

  Component.onCompleted: refresh()

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: countProbe
    command: ["swaync-client", "-c"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.notificationCount = Math.max(0, Number(text.trim()) || 0)
    }
  }

  Process {
    id: dndProbe
    command: ["swaync-client", "-D"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.dnd = text.trim() === "true"
    }
  }

  Process {
    id: panelToggle
    command: ["swaync-client", "-t", "-sw"]
    onExited: root.refresh()
  }

  Timer {
    id: panelToggleDelay
    interval: 200
    onTriggered: if (!panelToggle.running) panelToggle.running = true
  }

  Process {
    id: dndToggle
    command: ["swaync-client", "-d", "-sw"]
    onExited: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    active: root.notificationCount > 0 && !root.dnd
    tooltipText: root.dnd
      ? "Do Not Disturb"
      : (root.notificationCount > 0 ? root.notificationCount + " notifications" : "No notifications")

    onPressed: function(button) {
      if (button === Qt.RightButton) {
        if (!dndToggle.running) dndToggle.running = true
      } else if (!panelToggle.running) {
        if (root.bar && root.bar.activePopout) {
          root.bar.closeActivePopout()
          panelToggleDelay.restart()
        } else {
          panelToggle.running = true
        }
      }
    }
  }
}

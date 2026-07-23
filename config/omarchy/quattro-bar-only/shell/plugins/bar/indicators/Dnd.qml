import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool dnd: false

  active: dnd
  activeText: "󰂛"
  inactiveText: "󰂛"
  activeTooltipText: "Allow Notifications"
  inactiveTooltipText: "Silence Notifications"

  function refresh() {
    if (!statusProbe.running) statusProbe.running = true
  }

  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProbe
    command: ["swaync-client", "-D"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.dnd = text.trim() === "true"
    }
  }

  Process {
    id: toggleProcess
    command: ["swaync-client", "-d", "-sw"]
    onExited: root.refresh()
  }

  onPressed: function() {
    if (!toggleProcess.running) toggleProcess.running = true
  }
}

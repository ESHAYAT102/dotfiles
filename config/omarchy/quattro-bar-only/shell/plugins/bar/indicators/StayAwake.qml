import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool stayAwake: false

  active: stayAwake
  activeText: "󰅶"
  inactiveText: "󰅶"
  activeTooltipText: "Allow Idle Lock & Screensaver"
  inactiveTooltipText: "Stay Awake"

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
    command: ["bash", "-c", "pgrep -x hypridle >/dev/null && echo enabled || echo disabled"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.stayAwake = text.trim() !== "enabled"
    }
  }

  Process {
    id: toggleProcess
    command: ["bash", "-lc", "$HOME/.config/hypr/scripts/osd.sh idle-toggle"]
    onExited: root.refresh()
  }

  onPressed: function() {
    if (!toggleProcess.running) toggleProcess.running = true
  }
}

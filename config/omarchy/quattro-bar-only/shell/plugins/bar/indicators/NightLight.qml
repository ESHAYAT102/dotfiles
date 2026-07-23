import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool nightLightOn: false

  active: nightLightOn
  activeText: "󰔎"
  inactiveText: "󰔎"
  activeTooltipText: "Day Light"
  inactiveTooltipText: "Night Light"

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
    command: ["hyprctl", "hyprsunset", "temperature"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var temperature = Number(text.trim())
        root.nightLightOn = Number.isFinite(temperature) && temperature > 0 && temperature < 6000
      }
    }
  }

  Process {
    id: toggleProcess
    command: ["bash", "-lc", "$HOME/.config/hypr/scripts/osd.sh nightlight-toggle"]
    onExited: root.refresh()
  }

  onPressed: function() {
    if (!toggleProcess.running) toggleProcess.running = true
  }
}

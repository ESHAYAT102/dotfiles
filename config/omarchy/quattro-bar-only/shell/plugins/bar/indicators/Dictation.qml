import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property string state: "idle"
  property string icon: ""

  active: state === "recording"
  activeText: icon
  inactiveText: "󰍬"
  activeTooltipText: state
  inactiveTooltipText: "Dictate"

  function update(raw) {
    var data = extractData(raw)

    state = String(data.alt || data.class || "idle")
    if (state === "recording") icon = "󰍬"
    else if (state === "transcribing") icon = "󰔟"
    else icon = ""
  }

  function refresh() {
    if (!statusProbe.running) statusProbe.running = true
  }

  Component.onCompleted: refresh()

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProbe
    command: ["voxtype", "status", "--extended", "--format", "json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.update(text)
    }
  }

  Process {
    id: toggleProcess
    command: ["bash", "-lc", "systemctl --user start voxtype.service && voxtype record toggle"]
    onExited: root.refresh()
  }

  onPressed: function() {
    if (!toggleProcess.running) toggleProcess.running = true
  }
}

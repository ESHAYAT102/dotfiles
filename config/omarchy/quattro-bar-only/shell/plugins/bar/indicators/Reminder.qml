import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property int reminderCount: 0
  property string tooltip: ""

  active: reminderCount > 0
  activeText: "󰢌"
  inactiveText: "󰢌"
  activeTooltipText: tooltip
  inactiveTooltipText: tooltip

  function refresh() {
    if (!jsonProc.running) jsonProc.running = true
  }

  function update(raw) {
    reminderCount = Number(String(raw).trim() || 0)
    tooltip = reminderCount + (reminderCount === 1 ? " reminder" : " reminders")
  }

  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: jsonProc
    command: ["bash", "-lc", "systemctl --user list-timers --all --no-legend --no-pager 'omarchy-reminder-*.timer' 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.update(text)
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.reminderCount = 0
        root.tooltip = ""
      }
    }
  }

  onPressed: function() {
    if (root.bar) root.bar.run("env OMARCHY_PATH=$HOME/.config/omarchy/quattro-bar-only omarchy-shell shell summon omarchy.menu '{\"menu\":\"reminder\"}'")
  }
}

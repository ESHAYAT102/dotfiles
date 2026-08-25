import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property bool mediaPlaying: false
  property bool initialized: false

  readonly property string home: Quickshell.env("HOME")
  readonly property string stayAwakeDir: home + "/.local/state/omarchy/indicators"
  readonly property string stayAwakePath: stayAwakeDir + "/stay-awake"
  readonly property string markerPath: stayAwakeDir + "/stay-awake.media"

  function log(msg) {
    console.log("omarchy media-idle " + new Date().toISOString() + " " + msg)
  }

  function applyMediaState(playing) {
    var wasPlaying = root.mediaPlaying
    root.mediaPlaying = playing

    if (playing && !wasPlaying) {
      log("media-playing: inhibiting idle")
      mprisWriter.command = ["bash", "-c", "mkdir -p \"$HOME/.local/state/omarchy/indicators\" && touch \"$HOME/.local/state/omarchy/indicators/stay-awake\" \"$HOME/.local/state/omarchy/indicators/stay-awake.media\""]
      mprisWriter.running = true
    } else if (!playing && wasPlaying) {
      log("media-stopped: allowing idle")
      mprisWriter.command = ["bash", "-c", "rm -f \"$HOME/.local/state/omarchy/indicators/stay-awake.media\"; [[ -f \"$HOME/.local/state/omarchy/indicators/stay-awake\" ]] && rm -f \"$HOME/.local/state/omarchy/indicators/stay-awake\""]
      mprisWriter.running = true
    } else if (!playing && !wasPlaying && root.initialized) {
      // Cleanup stale marker from previous session (e.g. after shell restart while media was paused)
      mprisWriter.command = ["bash", "-c", "[[ -f \"$HOME/.local/state/omarchy/indicators/stay-awake.media\" ]] && rm -f \"$HOME/.local/state/omarchy/indicators/stay-awake.media\" \"$HOME/.local/state/omarchy/indicators/stay-awake\" || true"]
      mprisWriter.running = true
    }
    root.initialized = true
  }

  Timer {
    id: pollTimer
    interval: 5000
    repeat: true
    running: true
    onTriggered: {
      if (!mprisCheckProc.running) mprisCheckProc.running = true
    }
  }

  Process {
    id: mprisCheckProc
    command: ["bash", "-c", "busctl --user list 2>/dev/null | grep '^org\\.mpris\\.MediaPlayer2\\.' | awk '{print $1}' | while read player; do\n  status=$(gdbus introspect --session --dest \"$player\" --object-path /org/mpris/MediaPlayer2 2>/dev/null | grep 'PlaybackStatus' | head -1 | sed \"s/.*= *'\\(.*\\)'.*/\\1/\")\n  if [[ \"$status\" == \"Playing\" ]]; then\n    echo \"yes\"\n    break\n  fi\ndone"]
    stdout: SplitParser {
      onRead: function(line) {
        var playing = String(line).trim() === "yes"
        root.applyMediaState(playing)
      }
    }
    onExited: function(exitCode) {
      // If no output was produced (no playing media found), ensure state is updated
      if (!root.mediaPlaying) root.applyMediaState(false)
    }
  }

  Process {
    id: mprisWriter
    onExited: function(exitCode) {
      if (exitCode !== 0) log("write-failed exitCode=" + exitCode)
    }
  }

  Component.onCompleted: {
    log("service-ready")
    mprisCheckProc.running = true
  }
}

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

Item {
  id: root

  property var shell: null
  property var manifest: null
  property string omarchyPath: ""
  property string daemonState: "idle"
  property bool osdSuppressed: false
  property real peak: 0
  property bool vad: false
  readonly property var heightChoices: [5, 8, 11, 14, 17]
  readonly property int volumeLimit: root.listening
    ? Math.max(3, Math.min(root.heightChoices.length,
        1 + Math.ceil(Math.sqrt(Math.max(0, root.peak)) * 4)))
    : 3

  readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || ("/run/user/" + Quickshell.env("UID"))
  readonly property bool listening: daemonState === "recording" || daemonState === "streaming"
  readonly property bool active: daemonState !== "idle" && !osdSuppressed
  readonly property var focusedScreen: {
    var focusedName = Hyprland.focusedMonitor ? String(Hyprland.focusedMonitor.name || "") : ""
    var screens = Quickshell.screens || []
    for (var i = 0; i < screens.length; i++) {
      if (String(screens[i].name || "") === focusedName) return screens[i]
    }
    return screens.length > 0 ? screens[0] : null
  }

  function loadState(value) {
    var state = String(value || "idle").trim()
    daemonState = ["recording", "streaming", "transcribing"].indexOf(state) >= 0 ? state : "idle"
    if (!listening) {
      peak = 0
      vad = false
    }
  }

  function parseAudio(line) {
    var value = String(line || "").trim()
    if (!value) return
    try {
      var message = JSON.parse(value)
      if (message.status === "disconnected") {
        peak = 0
        vad = false
      } else {
        if (typeof message.peak === "number") peak = Math.max(0, Math.min(1, message.peak))
        if (typeof message.vad === "boolean") vad = message.vad
      }
    } catch (error) {
      // Ignore partial or informational bridge output.
    }
  }

  FileView {
    path: root.runtimeDir + "/voxtype/state"
    watchChanges: true
    printErrors: false
    onLoaded: root.loadState(text())
    onLoadFailed: root.daemonState = "idle"
    onFileChanged: reload()
  }

  FileView {
    path: root.runtimeDir + "/voxtype/osd_suppressed"
    watchChanges: true
    printErrors: false
    onLoaded: root.osdSuppressed = true
    onLoadFailed: root.osdSuppressed = false
    onFileChanged: reload()
  }

  Process {
    id: audioBridge
    command: ["/usr/bin/voxtype-audio-bridge"]
    running: root.listening
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(data) { root.parseAudio(data) }
    }
    onRunningChanged: {
      if (!running) {
        root.peak = 0
        root.vad = false
        if (root.listening) retryBridge.restart()
      }
    }
  }

  Timer {
    id: retryBridge
    interval: 1000
    onTriggered: if (root.listening && !audioBridge.running) audioBridge.running = true
  }

  PanelWindow {
    id: hudWindow
    screen: root.focusedScreen
    visible: root.active || pill.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "esh-voxtype-hud"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
      left: true
      right: true
      bottom: true
    }
    implicitHeight: 104

    Rectangle {
      id: pill
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      width: Math.min(parent.width - 32, 132)
      height: 34
      radius: height / 2
      color: Util.alpha(Color.background, 0.96)
      border.width: 1
      border.color: Util.alpha(Color.accent, 0.36)
      opacity: root.active ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
      }

      Row {
        anchors.centerIn: parent
        spacing: 2
        height: 28

        Repeater {
          model: 21

          Rectangle {
            required property int index
            property int selectedHeight: (index * 3 + 1) % root.heightChoices.length
            width: 3
            radius: height / 2
            y: (parent.height - height) / 2
            color: Color.foreground
            opacity: root.listening ? 0.96 : 0.68
            height: root.heightChoices[Math.min(selectedHeight, root.volumeLimit - 1)]

            Timer {
              interval: 465 + Math.random() * 410
              running: root.active
              repeat: true
              onTriggered: {
                var next = Math.floor(Math.random() * root.heightChoices.length)
                if (next === parent.selectedHeight)
                  next = (next + 1) % root.heightChoices.length
                parent.selectedHeight = next
                interval = 465 + Math.random() * 410
                restart()
              }
            }

            Behavior on height {
              NumberAnimation { duration: 320; easing.type: Easing.InOutSine }
            }

          }
        }
      }
    }
  }
}

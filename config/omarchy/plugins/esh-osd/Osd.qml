import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  property bool opened: false
  property string icon: ""
  property string message: ""
  property int value: 0
  property int maxValue: 100
  property bool hasProgress: true
  property int duration: 1500

  function iconFor(name, percent) {
    const n = String(name || "").toLowerCase()
    if (["volume-muted", "volume-mute", "muted", "mute"].indexOf(n) >= 0) return ""
    if (["volume-low", "volume-down"].indexOf(n) >= 0) return ""
    if (n === "volume-medium") return ""
    if (["volume-high", "volume", "volume-up", "volume-unmute"].indexOf(n) >= 0) return ""
    if (["microphone-muted", "microphone-off", "mic-muted", "mic-off"].indexOf(n) >= 0) return "󰍭"
    if (["microphone", "mic"].indexOf(n) >= 0) return "󰍬"
    if (["brightness", "display", "brightness-up", "brightness-down"].indexOf(n) >= 0) return "󰍹"
    if (n === "keyboard") return "󰌌"
    if (n === "touchpad") return "󰟸"
    if (n === "lock") return "󰌾"
    if (n === "screensaver") return "󰍹"
    if (n === "eye" || n === "eye-off") return "󰛨"
    if (n === "clock") return "󰥔"
    if (n === "battery") return "󰁹"
    if (percent <= 0) return ""
    if (percent <= 33) return ""
    if (percent <= 66) return ""
    return ""
  }

  function open(payloadJson) {
    try {
      const p = JSON.parse(payloadJson || "{}")
      const parsedValue = parseInt(p.value === undefined ? "" : String(p.value), 10)
      maxValue = Math.max(1, parseInt(p.max || "100", 10))
      hasProgress = p.value !== undefined && !isNaN(parsedValue) && !p.message
      value = hasProgress ? Math.max(0, Math.min(maxValue, parsedValue)) : 0
      const percent = hasProgress ? Math.round(value * 100 / maxValue) : -1
      icon = iconFor(p.icon, percent)
      message = String(p.message || (hasProgress ? (p.progressText || percent + "%") : ""))
      duration = Math.max(0, parseInt(p.duration || "1500", 10))
      opened = true
      if (duration > 0) hideTimer.restart()
    } catch (e) {}
  }

  function close() { opened = false }

  Timer {
    id: hideTimer
    interval: root.duration
    onTriggered: root.opened = false
  }

  IpcHandler {
    target: "esh-osd"
    function show(payloadJson: string): string { root.open(payloadJson); return "ok" }
    function close(): string { root.close(); return "ok" }
    function ping(): string { return "ok" }
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "esh-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    BorderSurface {
      id: card
      width: Style.space(269)
      height: Math.max(Style.space(68), Style.font.displayLarge + Style.spacing.panelGap)
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(67)
      color: Color.bar.background
      borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius

      Row {
        anchors.fill: parent
        anchors.margins: Style.space(16)
        spacing: Style.space(16)

        Text {
          width: Style.space(28)
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignHCenter
          text: root.icon
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Style.font.displayLarge
          color: Color.popups.text
        }
        Rectangle {
          visible: root.hasProgress
          width: visible ? Style.space(142) : 0
          height: Math.max(Style.space(6), Style.spacing.sm)
          anchors.verticalCenter: parent.verticalCenter
          radius: height / 2
          color: Util.alpha(Color.popups.text, 0.45)
          Rectangle {
            height: parent.height
            width: parent.width * root.value / root.maxValue
            radius: height / 2
            color: Color.accent
          }
        }
        Text {
          width: root.hasProgress ? Style.space(41) : Style.space(190)
          anchors.verticalCenter: parent.verticalCenter
          text: root.message
          font.family: Style.font.family
          font.bold: true
          font.pixelSize: Style.font.title
          color: Color.popups.text
          elide: Text.ElideRight
          maximumLineCount: 1
          clip: true
        }
      }
    }
  }
}

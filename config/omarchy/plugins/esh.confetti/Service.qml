pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root
  readonly property var colors: ["#ff4f64", "#ff8a00", "#ffd60a", "#ff5db1", "#9b6dff", "#5b8cff", "#31c5f4", "#72d572"]
  property int pendingBursts: 0
  signal burstRequested()

  function fire() {
    pendingBursts += 1
    if (!animationPreference.running) animationPreference.running = true
  }

  function releaseBursts(preference) {
    var enabled = String(preference || "").trim() !== "false"
    var bursts = pendingBursts
    pendingBursts = 0
    if (!enabled) return
    for (var i = 0; i < bursts; i++) burstRequested()
  }

  Process {
    id: animationPreference
    command: ["gsettings", "get", "org.gnome.desktop.interface", "enable-animations"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.releaseBursts(text)
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData
      visible: canvas.running
      anchors { top: true; right: true; bottom: true; left: true }
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      mask: Region {}
      WlrLayershell.namespace: "omarchy-confetti"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      Canvas {
        id: canvas
        anchors.fill: parent
        property var particles: []
        property bool running: false
        property double previousTime: 0

        function randomBetween(minimum, maximum) {
          return minimum + Math.random() * (maximum - minimum)
        }

        function makeParticle(screenWidth, screenHeight) {
          var left = Math.random() < 0.5
          var angle = left ? randomBetween(Math.PI * 1.5, Math.PI * 2) : randomBetween(Math.PI, Math.PI * 1.5)
          var speed = randomBetween(screenHeight * 0.68, screenHeight * 1.4)
          return {
            x: left ? 0 : screenWidth, y: screenHeight,
            vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed,
            size: randomBetween(8, 16), color: root.colors[Math.floor(Math.random() * root.colors.length)],
            rotation: randomBetween(0, Math.PI * 2), delay: randomBetween(0, 0.45), shape: Math.floor(Math.random() * 3)
          }
        }

        function fire() {
          var screenWidth = panel.screen ? panel.screen.width : width
          var screenHeight = panel.screen ? panel.screen.height : height
          if (screenWidth <= 0 || screenHeight <= 0) return
          if (!running) {
            particles = []
            previousTime = Date.now()
          }
          var next = particles.slice()
          for (var i = 0; i < 320; i++) next.push(makeParticle(screenWidth, screenHeight))
          particles = next
          running = true
          requestPaint()
        }

        function advance() {
          var now = Date.now()
          var dt = Math.min((now - previousTime) / 1000, 0.05)
          var alive = []
          previousTime = now
          for (var i = 0; i < particles.length; i++) {
            var particle = particles[i]
            if (particle.delay > 0) particle.delay -= dt
            else {
              particle.x += particle.vx * dt
              particle.y += particle.vy * dt
              particle.vy += height * 1.25 * dt
              particle.rotation += dt * 8
            }
            if (particle.delay > 0 || particle.y <= height + particle.size) alive.push(particle)
          }
          particles = alive
          requestPaint()
          if (particles.length === 0) running = false
        }

        onPaint: {
          var context = getContext("2d")
          context.clearRect(0, 0, width, height)
          context.globalAlpha = 0.95
          for (var i = 0; i < particles.length; i++) {
            var particle = particles[i]
            if (particle.delay > 0) continue
            context.save()
            context.translate(particle.x, particle.y)
            context.rotate(particle.rotation)
            context.fillStyle = particle.color
            context.beginPath()
            if (particle.shape === 0) context.rect(-particle.size / 2, -particle.size / 4, particle.size, particle.size / 2)
            else if (particle.shape === 1) context.arc(0, 0, particle.size / 3, 0, Math.PI * 2)
            else {
              context.moveTo(0, -particle.size / 2)
              context.lineTo(particle.size / 2, particle.size / 2)
              context.lineTo(-particle.size / 2, particle.size / 2)
              context.closePath()
            }
            context.fill()
            context.restore()
          }
          context.globalAlpha = 1
        }

        Timer {
          interval: 16
          repeat: true
          running: canvas.running
          onTriggered: canvas.advance()
        }

        Connections {
          target: root
          function onBurstRequested() { canvas.fire() }
        }
      }
    }
  }

  IpcHandler {
    target: "esh.confetti"
    function fire(): string {
      root.fire()
      return "ok"
    }
    function state(): string {
      return root.pendingBursts > 0 ? "pending" : "ready"
    }
  }
}

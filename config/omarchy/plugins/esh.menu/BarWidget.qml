import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "esh.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf303"
    fontFamily: "JetBrainsMono Nerd Font"
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-shell shell toggle esh.menu '{\"menu\":\"root\"}'")
    }
  }
}

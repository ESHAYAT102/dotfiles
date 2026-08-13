import QtQuick
import qs.Commons
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
    text: "󰣇"
    fontSize: Style.font.title
    horizontalMargin: 3
    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("env OMARCHY_PATH=/usr/share/omarchy omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
  }
}

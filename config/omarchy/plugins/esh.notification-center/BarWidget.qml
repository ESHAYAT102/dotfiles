import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "esh.notification-center"

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property var service: bar && bar.shell ? bar.shell.firstPartyServiceFor("omarchy.notifications") : null
  readonly property int liveCount: service && service.popupModel ? service.popupModel.count : 0
  readonly property bool unseen: panelLoader.item ? panelLoader.item.unseen === true : false

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("host" in target) target.host = root
  }

  function open() {
    if (panelLoader.item && panelLoader.item.open) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  function toggleDnd() {
    if (root.service) root.service.setDoNotDisturb(!root.service.doNotDisturb)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.service && root.service.doNotDisturb === true ? "\uf1f6" : "\uf0f3"
    tooltipText: root.service && root.service.doNotDisturb === true
      ? "DND on"
      : "Notification Center (" + root.liveCount + ")"
    onPressed: function(button) {
      if (button === Qt.RightButton) root.toggleDnd()
      else if (button === Qt.LeftButton) root.toggle()
    }
  }

  Rectangle {
    id: dot
    anchors.right: button.right
    anchors.top: button.top
    anchors.rightMargin: Style.space(3)
    anchors.topMargin: Style.space(3)
    visible: root.unseen && !root.opened
    width: Style.space(5)
    height: Style.space(5)
    radius: Math.round(height / 2)
    color: Color.urgent
    z: 10
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  moduleName: "esh.notifications"
  property bool popupOpen: false
  readonly property var notificationService: bar?.shell?.firstPartyServiceFor("omarchy.notifications")
  readonly property int pendingCount: notificationService ? notificationService.pendingModel.count : 0
  readonly property int pastCount: notificationService ? notificationService.pastModel.count : 0
  readonly property int totalCount: pendingCount + pastCount
  readonly property bool dnd: notificationService ? notificationService.doNotDisturb : false
  readonly property color dim: Qt.darker(Color.notifications.text, 1.35)

  function close() { popupOpen = false }
  function toggle() { popupOpen = !popupOpen }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.dnd ? "󰂛" : (root.pendingCount > 0 ? "󱅫" : "󰂚")
    active: root.pendingCount > 0 && !root.dnd
    tooltipText: root.dnd ? "Do Not Disturb" : root.totalCount + " notifications"
    onPressed: function(b) {
      if (b === Qt.RightButton && root.notificationService)
        root.notificationService.setDoNotDisturb(!root.dnd)
      else root.toggle()
    }
  }

  PopupCard {
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: fittedContentWidth(Style.space(440))
    contentHeight: cappedContentHeight(Style.space(540))

    ColumnLayout {
      anchors.fill: parent
      spacing: Style.spacing.md

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "Notifications" + (root.totalCount > 0 ? "  " + root.totalCount : "")
          font.family: root.bar?.fontFamily || ""
          font.pixelSize: Style.font.title
          font.bold: true
          color: Color.notifications.text
        }

        Item { Layout.fillWidth: true }

        Button {
          visible: root.totalCount > 0
          text: "Clear all"
          onClicked: if (root.notificationService) root.notificationService.dismissAll()
        }

        Button {
          text: root.dnd ? "DND on" : "DND off"
          selected: root.dnd
          onClicked: if (root.notificationService) root.notificationService.setDoNotDisturb(!root.dnd)
        }
      }

      Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: listColumn.implicitHeight
        clip: true

        Column {
          id: listColumn
          width: parent.width
          spacing: Style.spacing.md

          Repeater {
            model: root.notificationService ? root.notificationService.pendingModel : null
            delegate: NotificationRow {
              required property int index
              required property string app
              required property string appIcon
              required property string summary
              required property string body
              required property string image
              width: listColumn.width
              onDismiss: root.notificationService.dismissPending(index)
            }
          }

          Repeater {
            model: root.notificationService ? root.notificationService.pastModel : null
            delegate: NotificationRow {
              required property int index
              required property string app
              required property string appIcon
              required property string summary
              required property string body
              required property string image
              width: listColumn.width
              onDismiss: root.notificationService.dismissPast(index)
            }
          }

          Column {
            width: parent.width
            visible: root.totalCount === 0
            spacing: Style.spacing.md

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "󰂚"
              color: root.dim
              font.family: root.bar?.fontFamily || ""
              font.pixelSize: Style.font.displayLarge
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "No notifications"
              color: root.dim
              font.family: root.bar?.fontFamily || ""
              font.pixelSize: Style.font.body
            }
          }
        }
      }
    }
  }

  IpcHandler {
    target: "esh.notifications"
    function toggle(): void { root.toggle() }
    function open(): void { root.popupOpen = true }
    function close(): void { root.close() }
  }

  component NotificationRow: BorderSurface {
    id: row

    property string app: ""
    property string appIcon: ""
    property string summary: ""
    property string body: ""
    property string image: ""
    signal dismiss()

    implicitHeight: content.implicitHeight + Style.spacing.panelGap
    radius: Style.cornerRadius
    color: "transparent"
    borderSpec: Border.surfaceSpec("notifications", "border", Color.notifications.border, 1)

    RowLayout {
      id: content
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.margins: Style.spacing.lg
      spacing: Style.spacing.lg

      Image {
        Layout.preferredWidth: Style.space(28)
        Layout.preferredHeight: Style.space(28)
        source: row.image || Quickshell.iconPath(row.appIcon, true)
        fillMode: Image.PreserveAspectFit
        visible: source.toString().length > 0 && status !== Image.Error
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.spacing.xs
        Text {
          Layout.fillWidth: true
          text: row.summary || row.app
          color: Color.notifications.text
          font.family: root.bar?.fontFamily || ""
          font.pixelSize: Style.font.subtitle
          font.bold: true
          elide: Text.ElideRight
        }
        Text {
          Layout.fillWidth: true
          visible: row.body.length > 0
          text: row.body.replace(/<[^>]*>/g, "")
          color: root.dim
          font.family: root.bar?.fontFamily || ""
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
          maximumLineCount: 2
          elide: Text.ElideRight
        }
      }

      Button {
        text: "✕"
        onClicked: row.dismiss()
      }
    }
  }
}

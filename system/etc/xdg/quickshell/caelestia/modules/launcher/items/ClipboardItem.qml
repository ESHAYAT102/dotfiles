import QtQuick
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property var modelData
    required property var list

    implicitHeight: root.modelData?.isImage ? Tokens.sizes.launcher.itemHeight * 5.5 : Tokens.sizes.launcher.itemHeight
    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Tokens.rounding.large
        onClicked: root.modelData?.onClicked(root.list)
    }

    Item {
        anchors.fill: parent
        anchors.margins: Tokens.padding.small
        anchors.leftMargin: Tokens.padding.medium
        anchors.rightMargin: Tokens.padding.medium

        StyledClippingRect {
            id: preview
            anchors.horizontalCenter: root.modelData?.isImage ? parent.horizontalCenter : undefined
            anchors.left: root.modelData?.isImage ? undefined : parent.left
            anchors.top: root.modelData?.isImage ? parent.top : undefined
            anchors.verticalCenter: root.modelData?.isImage ? undefined : parent.verticalCenter
            implicitWidth: root.modelData?.isImage ? Math.min(parent.width, implicitHeight / 9 * 16) : Tokens.font.icon.large.pixelSize * 1.3
            implicitHeight: root.modelData?.isImage ? parent.height - info.implicitHeight - Tokens.spacing.medium : Tokens.font.icon.large.pixelSize * 1.3
            radius: root.modelData?.isImage ? Tokens.rounding.large : 0
            color: root.modelData?.isImage ? Colours.tPalette.m3surfaceContainer : "transparent"

            MaterialIcon {
                anchors.centerIn: parent
                visible: !root.modelData?.isImage
                text: root.modelData?.icon ?? "content_paste"
                color: Colours.palette.m3primary
                fontStyle: Tokens.font.icon.builders.large.scale(1.3).build()
            }

            Image {
                anchors.fill: parent
                visible: root.modelData?.isImage ?? false
                asynchronous: true
                cache: true
                fillMode: Image.PreserveAspectFit
                source: root.modelData?.isImage ? `file://${root.modelData.previewPath}` : ""
            }
        }

        Item {
            id: info
            anchors.left: root.modelData?.isImage ? preview.left : preview.right
            anchors.right: root.modelData?.isImage ? preview.right : parent.right
            anchors.leftMargin: root.modelData?.isImage ? 0 : Tokens.spacing.medium
            anchors.top: root.modelData?.isImage ? preview.bottom : undefined
            anchors.topMargin: root.modelData?.isImage ? Tokens.spacing.small : 0
            anchors.verticalCenter: root.modelData?.isImage ? undefined : preview.verticalCenter
            implicitHeight: name.implicitHeight + desc.implicitHeight

            StyledText {
                id: name
                width: parent.width
                text: root.modelData?.name ?? ""
                elide: Text.ElideRight
                font: Tokens.font.body.medium
            }

            StyledText {
                id: desc
                anchors.top: name.bottom
                width: parent.width
                text: root.modelData?.desc ?? ""
                elide: Text.ElideRight
                color: Colours.palette.m3outline
                font: Tokens.font.body.small
            }
        }
    }
}

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root
    required property var modelData
    required property var list
    implicitHeight: Tokens.sizes.launcher.itemHeight
    anchors.left: parent?.left
    anchors.right: parent?.right

    StyledRect {
        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.palette.m3primary
        opacity: root.modelData?.isSelected ? 0.14 : 0
    }

    StateLayer { radius: Tokens.rounding.large; onClicked: root.modelData?.onClicked(root.list) }
    Item {
        anchors.fill: parent
        anchors.margins: Tokens.padding.small
        anchors.leftMargin: Tokens.padding.medium
        anchors.rightMargin: Tokens.padding.medium
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: name.implicitHeight + desc.implicitHeight
            StyledText { id: name; width: parent.width; text: root.modelData?.name ?? ""; elide: Text.ElideRight; color: root.modelData?.isSelected ? Colours.palette.m3primary : Colours.palette.m3onSurface; font: Tokens.font.body.medium }
            StyledText { id: desc; anchors.top: name.bottom; width: parent.width; text: root.modelData?.desc ?? ""; elide: Text.ElideRight; color: Colours.palette.m3outline; font: Tokens.font.body.small }
        }
    }
}

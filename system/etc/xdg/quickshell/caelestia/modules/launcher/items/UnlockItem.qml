import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.services

Item {
    id: root
    required property string themeName
    required property string themePath
    required property var screenState
    function applyUnlock(): void {
        root.screenState.launcher = false;
        Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", `omarchy-plymouth-set-by-theme '${root.themeName}'`]);
    }
    scale: PathView.isCurrentItem ? 1 : PathView.onPath ? 0.8 : 0
    opacity: PathView.onPath ? 1 : 0
    z: PathView.z ?? 0
    implicitWidth: image.width + Tokens.padding.medium * 2
    implicitHeight: image.height + label.height + Tokens.spacing.extraSmall + Tokens.padding.large + Tokens.padding.medium
    StateLayer { radius: Tokens.rounding.large; onClicked: root.applyUnlock() }
    Elevation { anchors.fill: image; radius: image.radius; opacity: root.PathView.isCurrentItem ? 1 : 0; level: 4 }
    StyledClippingRect {
        id: image
        anchors.horizontalCenter: parent.horizontalCenter
        y: Tokens.padding.large
        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.large
        implicitWidth: Tokens.sizes.launcher.wallpaperWidth
        implicitHeight: implicitWidth / 16 * 9
        Image { anchors.fill: parent; source: `file://${root.themePath}/preview-unlock.png`; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: true }
    }
    StyledText {
        id: label
        anchors.top: image.bottom
        anchors.topMargin: Tokens.spacing.extraSmall
        anchors.horizontalCenter: parent.horizontalCenter
        width: image.width - Tokens.padding.medium * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        text: root.themeName.split("-").join(" ")
        font: Tokens.font.label.medium
    }
    Behavior on scale { Anim {} }
    Behavior on opacity { Anim { type: Anim.DefaultEffects } }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Caelestia
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Column {
    id: root

    required property ScreenState screenState

    padding: Tokens.padding.large
    rightPadding: CUtils.clamp(padding - Config.border.thickness, 0, padding)
    spacing: Tokens.spacing.large

    SessionButton {
        id: screensaver
        icon: "monitor"
        tooltip: qsTr("Screensaver")
        command: ["omarchy-launch-screensaver", "force"]
        KeyNavigation.down: lock
        Component.onCompleted: forceActiveFocus()

        Connections {
            function onLauncherChanged(): void {
                if (!root.screenState.launcher)
                    screensaver.forceActiveFocus();
            }

            target: root.screenState
        }
    }

    SessionButton {
        id: lock
        icon: "lock"
        tooltip: qsTr("Lock")
        command: ["caelestia", "shell", "lock", "lock"]
        KeyNavigation.up: screensaver
        KeyNavigation.down: suspend
    }

    SessionButton {
        id: suspend
        icon: "bedtime"
        tooltip: qsTr("Suspend")
        command: ["systemctl", "suspend"]
        KeyNavigation.up: lock
        KeyNavigation.down: logout
    }

    SessionButton {
        id: logout
        icon: "logout"
        tooltip: qsTr("Log out")
        command: ["omarchy-system-logout"]
        KeyNavigation.up: suspend
        KeyNavigation.down: reboot
    }

    SessionButton {
        id: reboot
        icon: "restart_alt"
        tooltip: qsTr("Restart")
        command: ["omarchy-system-reboot"]
        KeyNavigation.up: logout
        KeyNavigation.down: shutdown
    }

    SessionButton {
        id: shutdown
        icon: "power_settings_new"
        tooltip: qsTr("Shut down")
        command: ["omarchy-system-shutdown"]
        KeyNavigation.up: reboot
    }

    component SessionButton: IconButton {
        id: button

        required property list<string> command
        required property string tooltip

        function exec(): void {
            if (!SessionManager.exec(command))
                Quickshell.execDetached(command);
        }

        implicitWidth: Tokens.sizes.session.button
        implicitHeight: Tokens.sizes.session.button

        inactiveColour: activeFocus ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer
        inactiveOnColour: activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
        radius: pressed ? Tokens.rounding.medium : activeFocus ? Tokens.rounding.extraLarge : Tokens.rounding.largeIncreased
        font: Tokens.font.icon.builders.large.scale(1.3).build()
        onClicked: exec()

        ToolTip {
            id: sessionTooltip

            parent: button
            visible: button.hovered
            text: button.tooltip
            delay: 450
            timeout: 4000
            x: -implicitWidth - Tokens.spacing.medium
            y: Math.round((button.height - implicitHeight) / 2)
            leftPadding: Tokens.padding.medium
            rightPadding: Tokens.padding.medium
            topPadding: Tokens.padding.small
            bottomPadding: Tokens.padding.small

            contentItem: StyledText {
                text: sessionTooltip.text
                color: Colours.palette.m3onSurface
                font: Tokens.font.label.medium
            }

            background: StyledRect {
                color: Colours.tPalette.m3surfaceContainerHigh
                radius: Tokens.rounding.medium
                border.width: 1
                border.color: Qt.alpha(Colours.palette.m3outline, 0.35)
            }
        }

        Keys.onEnterPressed: exec()
        Keys.onReturnPressed: exec()
        Keys.onEscapePressed: root.screenState.session = false
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if ((event.key === Qt.Key_J || event.key === Qt.Key_N) && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if ((event.key === Qt.Key_K || event.key === Qt.Key_P) && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }
    }
}

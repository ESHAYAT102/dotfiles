pragma ComponentBehavior: Bound

import QtQuick
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
        command: ["caelestia", "shell", "lock", "lock"]
        KeyNavigation.up: screensaver
        KeyNavigation.down: suspend
    }

    SessionButton {
        id: suspend
        icon: "bedtime"
        command: ["systemctl", "suspend"]
        KeyNavigation.up: lock
        KeyNavigation.down: hibernate
    }

    SessionButton {
        id: hibernate
        icon: "mode_off_on"
        command: ["systemctl", "hibernate"]
        KeyNavigation.up: suspend
        KeyNavigation.down: logout
    }

    SessionButton {
        id: logout
        icon: "logout"
        command: ["omarchy-system-logout"]
        KeyNavigation.up: hibernate
        KeyNavigation.down: reboot
    }

    SessionButton {
        id: reboot
        icon: "restart_alt"
        command: ["omarchy-system-reboot"]
        KeyNavigation.up: logout
        KeyNavigation.down: shutdown
    }

    SessionButton {
        id: shutdown
        icon: "power_settings_new"
        command: ["omarchy-system-shutdown"]
        KeyNavigation.up: reboot
    }

    component SessionButton: IconButton {
        id: button

        required property list<string> command

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

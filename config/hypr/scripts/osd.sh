#!/bin/bash

TAG="osd_notification"
STEP="${2:-5}"
ICON_DIR="$HOME/.config/hypr/icons"
STATE_FILE="$HOME/.local/state/omarchy/toggles/screensaver-off"
TIMEOUT=1500

ON_TEMP=4000
OFF_TEMP=6000

send_notification() {
    local label=$1
    local value=$2
    local icon_file=$3
    if [[ $value =~ ^[0-9]+$ ]]; then
        notify-send -e -h string:x-canonical-private-synchronous:$TAG \
            -u critical \
            -t $TIMEOUT \
            -i "$ICON_DIR/$icon_file" \
            "$value%" "$label" 
    else
        notify-send -e -h string:x-canonical-private-synchronous:$TAG \
            -u critical \
            -t $TIMEOUT \
            -i "$ICON_DIR/$icon_file" \
            "$value" "$label"
    fi
}

case $1 in
    vol-up)
        pamixer -u && pamixer -i "$STEP"
        send_notification "Volume" "$(pamixer --get-volume)" "volume-up.svg"
        ;;
    vol-down)
        pamixer -u && pamixer -d "$STEP"
        send_notification "Volume" "$(pamixer --get-volume)" "volume-down.svg"
        ;;
    vol-mute)
        pamixer -t
        if [ "$(pamixer --get-mute)" = "true" ]; then
            send_notification "Volume" "Muted" "volume-muted.svg"
        else
            send_notification "Volume" "$(pamixer --get-volume)" "volume-unmute.svg"
        fi
        ;;
    mic-mute)
        pamixer --default-source -t
        if [ "$(pamixer --default-source --get-mute)" = "true" ]; then
            send_notification "Microphone" "Muted" "mic-muted.svg"
        else
            send_notification "Microphone" "Active" "mic.svg"
        fi
        ;;
    bright-up)
        brightnessctl set "$STEP"%+
        BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d %)
        send_notification "Brightness" "$BRIGHT" "brightness-up.svg"
        ;;
    bright-down)
        brightnessctl set "$STEP"%-
        BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d %)
        send_notification "Brightness" "$BRIGHT" "brightness-down.svg"
        ;;
    idle-toggle)
        if pgrep -x hypridle >/dev/null; then
            pkill -x hypridle
            send_notification "Idle Locking" "Disabled" "lock.svg"
        else
            uwsm-app -- hypridle >/dev/null 2>&1 &
            send_notification "Idle Locking" "Enabled" "lock.svg"
        fi
        ;;
    screensaver-toggle)
        if [[ -f $STATE_FILE ]]; then
            rm -f "$STATE_FILE"
            send_notification "Screensaver" "Enabled" "screensaver.svg"
        else
            mkdir -p "$(dirname "$STATE_FILE")"
            touch "$STATE_FILE"
            send_notification "Screensaver" "Disabled" "screensaver.svg"
        fi
        ;;
    nightlight-toggle)
        if ! pgrep -x hyprsunset >/dev/null; then
            setsid uwsm-app -- hyprsunset &
            sleep 0.5
        fi
        CURRENT_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')
        if [[ "$CURRENT_TEMP" == "$OFF_TEMP" ]]; then
            hyprctl hyprsunset temperature $ON_TEMP
            send_notification "Nightlight" "Enabled" "eye.svg"
        else
            hyprctl hyprsunset temperature $OFF_TEMP
            send_notification "Nightlight" "Disabled" "eye-off.svg"
        fi
        ;;
    time)
        TIME_NOW=$(date +"%I:%M:%S %p")
        DATE_NOW=$(date +"%A, %d %B")
        send_notification "$DATE_NOW" "$TIME_NOW" "clock.svg"
        ;;
    battery)
        BAT_VAL=$(omarchy-battery-remaining)
        send_notification "Battery" "$BAT_VAL" "battery.svg"
        ;;
    layout-toggle)
        CURRENT_LAYOUT=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}' | tr -d '"')
        if [ "$CURRENT_LAYOUT" = "dwindle" ]; then
            hyprctl keyword general:layout scrolling
            send_notification "Layout" "Scrolling" "desktop.svg"
        else
            hyprctl keyword general:layout dwindle
            send_notification "Layout" "Dwindle" "desktop.svg"
        fi
        ;;
esac

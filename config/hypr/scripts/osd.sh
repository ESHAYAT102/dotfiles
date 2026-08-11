#!/bin/bash

TAG="osd_notification"
STEP="${2:-5}"
ICON_DIR="$HOME/.config/hypr/icons"
STATE_FILE="$HOME/.local/state/omarchy/toggles/screensaver-off"
TIMEOUT=1500

ON_TEMP=4000
OFF_TEMP=6000

is_caelestia_mode() {
    local mode_file="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-shell-mode"
    [[ ! -r "$mode_file" || "$(<"$mode_file")" == "caelestia" ]]
}

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

send_toggle_osd() {
    local title=$1
    local state=$2
    local icon=$3

    if is_caelestia_mode; then
        # Use Caelestia's compact toast overlay instead of creating a normal
        # notification that gets stored in the notification centre.
        caelestia shell toaster info "$title" "$state" "$icon" >/dev/null 2>&1 || true
    else
        send_notification "$title" "$state" "$4"
    fi
}

set_brightness() {
    local target=$1
    local icon_file=$2
    local mode_file="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-shell-mode"
    local mode="caelestia"

    [[ -r "$mode_file" ]] && mode="$(<"$mode_file")"
    if [[ "$mode" == "caelestia" ]]; then
        caelestia shell brightness set "${target}%" >/dev/null
    else
        brightnessctl set "${target}%" >/dev/null
        send_notification "Brightness" "$target" "$icon_file"
    fi
}

case $1 in
    vol-up)
        pamixer -u && pamixer -i "$STEP"
        is_caelestia_mode || send_notification "Volume" "$(pamixer --get-volume)" "volume-up.svg"
        ;;
    vol-down)
        pamixer -u && pamixer -d "$STEP"
        is_caelestia_mode || send_notification "Volume" "$(pamixer --get-volume)" "volume-down.svg"
        ;;
    vol-mute)
        pamixer -t
        if [ "$(pamixer --get-mute)" = "true" ]; then
            is_caelestia_mode || send_notification "Volume" "Muted" "volume-muted.svg"
        else
            is_caelestia_mode || send_notification "Volume" "$(pamixer --get-volume)" "volume-unmute.svg"
        fi
        ;;
    mic-mute)
        pamixer --default-source -t
        if [ "$(pamixer --default-source --get-mute)" = "true" ]; then
            is_caelestia_mode || send_notification "Microphone" "Muted" "mic-muted.svg"
        else
            is_caelestia_mode || send_notification "Microphone" "Active" "mic.svg"
        fi
        ;;
    bright-up)
        BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d %)
        TARGET=$((BRIGHT + STEP))
        ((TARGET > 100)) && TARGET=100
        set_brightness "$TARGET" "brightness-up.svg"
        ;;
    bright-down)
        BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d %)
        TARGET=$((BRIGHT - STEP))
        ((TARGET < 0)) && TARGET=0
        set_brightness "$TARGET" "brightness-down.svg"
        ;;
    bright-max)
        set_brightness 100 "brightness-up.svg"
        ;;
    bright-min)
        set_brightness 0 "brightness-down.svg"
        ;;
    idle-toggle)
        if pgrep -x hypridle >/dev/null; then
            pkill -x hypridle
            if is_caelestia_mode; then
                caelestia shell idleInhibitor enable >/dev/null
            fi
            send_toggle_osd "Idle Locking" "Disabled" "lock_open" "lock.svg"
        else
            uwsm-app -- hypridle >/dev/null 2>&1 &
            if is_caelestia_mode; then
                caelestia shell idleInhibitor disable >/dev/null
            fi
            send_toggle_osd "Idle Locking" "Enabled" "lock" "lock.svg"
        fi
        ;;
    screensaver-toggle)
        if [[ -f $STATE_FILE ]]; then
            rm -f "$STATE_FILE"
            send_toggle_osd "Screensaver" "Enabled" "screensaver" "screensaver.svg"
        else
            mkdir -p "$(dirname "$STATE_FILE")"
            touch "$STATE_FILE"
            send_toggle_osd "Screensaver" "Disabled" "screen_lock_portrait" "screensaver.svg"
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
            send_toggle_osd "Nightlight" "Enabled" "nightlight" "eye.svg"
        else
            hyprctl hyprsunset temperature $OFF_TEMP
            send_toggle_osd "Nightlight" "Disabled" "nightlight_round" "eye-off.svg"
        fi
        ;;
    time)
        TIME_NOW=$(date +"%I:%M:%S %p")
        DATE_NOW=$(date +"%A, %d %B")
        send_notification "$DATE_NOW" "$TIME_NOW" "clock.svg"
        ;;
    battery)
        BAT_VAL=$(omarchy-battery-remaining)
        BAT_REM=$(omarchy-battery-remaining-time)
        send_notification "Battery" "$BAT_VAL% — $BAT_REM" "battery.svg"
        ;;
esac

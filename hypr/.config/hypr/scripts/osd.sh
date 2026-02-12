#!/bin/bash

TAG="osd_notification" 
STEP="${2:-5}"
ICON_DIR="$HOME/.config/hypr/icons"

send_notification() {
    local label=$1
    local value=$2
    local icon_file=$3
    
    notify-send -e -h string:x-canonical-private-synchronous:$TAG \
        -h int:value:"$value" \
        -u low \
        -i "$ICON_DIR/$icon_file" \
        "$label" "$value%"
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
            send_notification "Muted" "0" "volume-muted.svg"
        else
            send_notification "Volume" "$(pamixer --get-volume)" "volume-unmute.svg"
        fi
        ;;
    mic-mute)
        pamixer --default-source -t
        if [ "$(pamixer --default-source --get-mute)" = "true" ]; then
            send_notification "Microphone" "0" "mic-muted.svg"
        else
            send_notification "Microphone" "100" "mic.svg"
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
esac


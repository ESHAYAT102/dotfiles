#!/bin/bash

CURRENT_LAYOUT=$(hyprctl getoption general:layout | grep "str:" | awk '{print $2}' | tr -d '"')

if [ "$CURRENT_LAYOUT" = "scrolling" ]; then
    hyprctl dispatch layoutmsg "$@"
fi

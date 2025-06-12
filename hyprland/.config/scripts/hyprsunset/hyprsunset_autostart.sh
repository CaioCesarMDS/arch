#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/hyprsunset"
mkdir -p "$CONFIG_DIR"

MANUAL_MODE_FILE="$CONFIG_DIR/hyprsunset_manual"
TEMP_FILE="$CONFIG_DIR/hyprsunset_temperature"

if [ -e "$MANUAL_MODE_FILE" ]; then
    if ! pgrep -x hyprsunset > /dev/null; then
        notify-send "Hyprland" "Starting Hyprsunset automatically"
        temp=$(cat "$TEMP_FILE" 2>/dev/null || echo 2800)
        hyprsunset -t "$temp" &
    fi
    exit 0
fi

current_time=$(date +%H)

if [ "$current_time" -ge 18 ] || [ "$current_time" -le 6 ]; then
    desired_temp=2800
else
    desired_temp=6000
fi

if [ -f "$TEMP_FILE" ]; then
    current_temp=$(cat "$TEMP_FILE")
else
    current_temp=0
fi

if [ "$current_temp" -ne "$desired_temp" ]; then
    hyprsunset -t "$desired_temp" &
    echo "$desired_temp" > "$TEMP_FILE"
fi

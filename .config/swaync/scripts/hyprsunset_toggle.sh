#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/hyprsunset"
mkdir -p "$CONFIG_DIR"

MANUAL_MODE_FILE="$CONFIG_DIR/hyprsunset_manual"
TEMP_FILE="$CONFIG_DIR/hyprsunset_temperature"

desired_temp=4800

if pgrep -x hyprsunset > /dev/null; then
    pkill hyprsunset
    rm -f "$TEMP_FILE" "$MANUAL_MODE_FILE"
else
    notify-send "Hyprland" "Starting Hyprsunset"
    hyprsunset -t $desired_temp &
    echo $desired_temp > "$TEMP_FILE"
    touch "$MANUAL_MODE_FILE"
fi

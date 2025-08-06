#!/bin/bash

LOCKFILE="/tmp/hyprsunset_toggle.lock"

exec 200>"$LOCKFILE"
flock -n 200 || exit 1

sleep 0.3

CONFIG_DIR="$HOME/.config/hyprsunset"
mkdir -p "$CONFIG_DIR"

MANUAL_MODE_FILE="$CONFIG_DIR/hyprsunset_manual"
desired_temp=2800

if [ -f "$MANUAL_MODE_FILE" ]; then
  notify-send "Hyprland" "Stopping Hyprsunset"
  pkill hyprsunset
  rm -f "$MANUAL_MODE_FILE"
  flock -u 200
  exec 200>&-
  exit 0
else
notify-send "Hyprland" "Starting Hyprsunset"
  hyprsunset -t "$desired_temp" &
  touch "$MANUAL_MODE_FILE"
  flock -u 200        
  exec 200>&-         
  exit 0
fi


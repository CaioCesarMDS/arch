#!/bin/bash

CONFIG_DIR="$HOME/.config/hyprsunset"
MANUAL_MODE_FILE="$CONFIG_DIR/hyprsunset_manual"
SWAYNC_CONFIG="$HOME/.config/swaync/config.json"

if [ ! -f "$SWAYNC_CONFIG" ]; then
    exit 1
fi

if ! jq empty "$SWAYNC_CONFIG" >/dev/null 2>&1; then
    exit 1
fi

if [ -e "$MANUAL_MODE_FILE" ]; then
    active=true
    if ! pgrep -x hyprsunset >/dev/null; then
        "$CONFIG_DIR/auto_start.sh" &>/dev/null &
    fi
else
    active=false
fi

tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

jq --argjson active "$active" '
  .["widget-config"]["buttons-grid"]["actions"] |=
    map(
      if .command and (.command | test("hyprsunset_toggle.sh")) then
        .active = $active
      else
        .
      end
    )
' "$SWAYNC_CONFIG" > "$tmp_file" && mv "$tmp_file" "$SWAYNC_CONFIG"

#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/hyprsunset"
MANUAL_MODE_FILE="$CONFIG_DIR/hyprsunset_manual"
SWAYNC_CONFIG="$HOME/.config/swaync/config.json"

if [ ! -f "$SWAYNC_CONFIG" ]; then
    echo "Error: $SWAYNC_CONFIG not found."
    exit 1
fi

if [ -e "$MANUAL_MODE_FILE" ]; then
    active=true
else
    active=false
fi

tmp_file=$(mktemp)
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

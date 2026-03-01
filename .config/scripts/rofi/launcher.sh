#!/usr/bin/env bash
set -euo pipefail

pkill -u "$USER" -x rofi 2>/dev/null || true

readonly LAUNCHER_THEME_FILE="$HOME/.config/rofi/launcher.rasi"

[ -f "$LAUNCHER_THEME_FILE" ] || { echo "File not found: $LAUNCHER_THEME_FILE" >&2; exit 1; }

rofi -show drun -theme "$LAUNCHER_THEME_FILE"

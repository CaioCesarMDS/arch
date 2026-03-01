#!/usr/bin/env bash

output=""

check_battery() {
  local BAT_PATH="/sys/class/power_supply/BAT1"

  if [[ ! -d "$BAT_PATH" ]]; then
    output+=" 100%"
    return
  fi

  local status capacity icon
  status="$(cat "$BAT_PATH/status")"
  capacity="$(cat "$BAT_PATH/capacity")"

  case $((capacity / 9)) in
  0) icon="󰂎" ;;
  1) icon="󰁺" ;;
  2) icon="󰁻" ;;
  3) icon="󰁼" ;;
  4) icon="󰁽" ;;
  5) icon="󰁾" ;;
  6) icon="󰁿" ;;
  7) icon="󰂀" ;;
  8) icon="󰂁" ;;
  9 | 10) icon="󰂂" ;;
  *) icon="󰁹" ;;
  esac

  case "$status" in
  Charging) output+="󰂄 $capacity%" ;;
  Full) output+="󰁹 $capacity%" ;;
  Discharging) output+="$icon $capacity%" ;;
  *) output+=" $capacity%" ;;
  esac
}

check_battery
echo "$output"

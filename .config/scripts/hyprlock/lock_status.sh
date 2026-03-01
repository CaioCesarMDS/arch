#!/usr/bin/env bash

output=""

check_lock() {
  local type=$1 label=$2
  for led in /sys/class/leds/input*::"$type"/brightness; do
    [[ -f "$led" ]] && [[ "$(cat "$led")" == "1" ]] && {
      output+="$label "
      break
    }
  done
}

check_lock "capslock" "Caps 󰪛"
check_lock "numlock" "Num "

echo "$output"

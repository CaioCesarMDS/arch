#!/bin/sh
if pgrep -x hyprsunset >/dev/null; then
    pkill hyprsunset
else
    notify-send "Hyprland" "Starting Hyprsunset"
    current_time=$(date +%H)

    if [ "$current_time" -ge 18 ] || [ "$current_time" -le 6 ]; then
        hyprsunset -t 4800 &
    else
        hyprsunset -t 6000 &
    fi
fi

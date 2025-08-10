#!/usr/bin/env bash

set -euo pipefail

get_best_monitor() {
    monitors_output=$(hyprctl monitors)
    monitor_name=$(echo "$monitors_output" | grep -oP '^Monitor\s+\K\S+')
    modes_line=$(echo "$monitors_output" | grep -oP 'availableModes:\s+\K.*')

    IFS=' ' read -ra modes_array <<<"$modes_line"

    best_resolution=""
    best_refresh=0
    best_pixels=0

    get_pixels() {
        local res=$1
        local width=${res%x*}
        local height=${res#*x}
        echo $((width * height))
    }

    for mode in "${modes_array[@]}"; do
        res=${mode%@*}
        hz=${mode#*@}
        hz=${hz%Hz}

        pixels=$(get_pixels "$res")

        if ((pixels > best_pixels)) ||
            ((pixels == best_pixels && $(awk "BEGIN {print ($hz > $best_refresh)}"))); then
            best_resolution="$res"
            best_refresh="$hz"
            best_pixels="$pixels"
        fi
    done
}

echo "monitor=$monitor_name,${best_resolution}@${best_refresh},auto,1"

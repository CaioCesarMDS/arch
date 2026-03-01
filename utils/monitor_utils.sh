#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="$(dirname "$(realpath "$0")")"

source "$SRC_DIR/utils/global_func.sh"

# Get the best monitor configuration for hyprland config
get_best_monitor() {

    if ! monitors_output=$(hyprctl monitors 2>&1); then
        log_warn "Hyprland not running or cannot get monitors: $monitors_output"
        echo "monitor=DP-1,1920x1080@60,auto,1"
        return 0
    fi

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

    echo "monitor=$monitor_name,${best_resolution}@${best_refresh},auto,1"
}

# Replace the monitor line in the hyprland config
replace_monitor_line() {
    local conf_file="$1"
    local new_monitor_line
    new_monitor_line=$(get_best_monitor)

    sed -i "s/^monitor=.*/$new_monitor_line/" "$conf_file"
}

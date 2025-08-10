#!/usr/bin/env bash

set -euo pipefail

scrDir="$(dirname "$(realpath "$0")")"

source "$scrDir/utils/global_func.sh"
source "$scrDir/core/env.sh"
source "$scrDir/utils/monitor_info.sh"

CONFIG_SRC="$scrDir/.config"
CONFIG_DEST="$USER_HOME/.config"

WALLPAPER_SRC="$scrDir/assets/Wallpapers"
WALLPAPER_DEST="$USER_HOME/Wallpapers"

WAYBAR_CONFIG_DIR="$CONFIG_SRC/waybar"
SWAYNC_CONFIG_DIR="$CONFIG_SRC/swaync"

DEVICE_TYPE=$(detect_device_type)

copy_configs() {
    log_info "Copying configs to $CONFIG_DEST..."

    mkdir -p "$CONFIG_DEST"

    cp -r "$CONFIG_SRC/"* "$CONFIG_DEST/"

    if [[ "$DEVICE_TYPE" == "laptop" ]]; then

        convert_ddcutil_to_brightnessctl "$CONFIG_DEST/hypr/hypridle.conf"
        replace_monitor_line "$CONFIG_DEST/hypr/hyprland.conf"

        if [[ -d "$CONFIG_SRC/waybar/laptop" ]]; then
            cp -r "$CONFIG_SRC/waybar/laptop/"* "$CONFIG_DEST/waybar/"
        fi
        if [[ -d "$CONFIG_SRC/swaync/laptop" ]]; then
            cp -r "$CONFIG_SRC/swaync/laptop/"* "$CONFIG_DEST/swaync/"
        fi

    else
        rm -rf "$CONFIG_DEST/waybar/laptop" "$CONFIG_DEST/swaync/laptop"
    fi

    chown -R "$CURRENT_USER":"$CURRENT_USER" "$CONFIG_DEST"
}

copy_wallpapers() {
    log_info "Copying wallpapers to $WALLPAPER_DEST..."

    if [[ ! -d "$WALLPAPER_SRC" ]]; then
        log_error "Wallpaper directory not found."
        exit 1
    fi

    mkdir -p "$WALLPAPER_DEST"
    cp -r "$WALLPAPER_SRC/"* "$WALLPAPER_DEST/"
    chown -R "$CURRENT_USER":"$CURRENT_USER" "$WALLPAPER_DEST"
}

enable_sddm() {
    log_info "Enabling SDDM service..."
    systemctl enable sddm.service
}

main() {
    log_info "Starting Hyprland configuration..."

    copy_configs
    copy_wallpapers
    enable_sddm

    log_info "✅ Hyprland configuration completed successfully."
}

main

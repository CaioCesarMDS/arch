#!/usr/bin/env bash

set -euo pipefail

scrDir="$(dirname "$(realpath "$0")")"

source "$scrDir/utils/global_func.sh"
source "$scrDir/core/env.sh"

CONFIG_SRC="$scrDir/.config"
CONFIG_DEST="$USER_HOME/.config"

WALLPAPER_SRC="$scrDir/assets/Wallpapers"
WALLPAPER_DEST="$USER_HOME/Wallpapers"

DEVICE_TYPE=$(detect_device_type)

copy_configs() {
    log_info "Copying configuration files to $CONFIG_DEST..."

    if [[ ! -d "$CONFIG_SRC/shared" ]]; then
        log_error "Shared config directory not found."
        exit 1
    fi

    mkdir -p "$CONFIG_DEST"
    cp -r "$CONFIG_SRC/shared/"* "$CONFIG_DEST/"

    if [[ "$DEVICE_TYPE" == "laptop" ]]; then
        log_info "Copying laptop-specific configuration files..."
        if [[ -d "$CONFIG_SRC/laptop" ]]; then
            cp -r "$CONFIG_SRC/laptop/"* "$CONFIG_DEST/"
        else
            log_error "Laptop config directory not found."
            exit 1
        fi
    else
        log_info "Copying desktop-specific configuration files..."
        if [[ -d "$CONFIG_SRC/desktop" ]]; then
            cp -r "$CONFIG_SRC/desktop/"* "$CONFIG_DEST/"
        else
            log_error "Desktop config directory not found."
            exit 1
        fi
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

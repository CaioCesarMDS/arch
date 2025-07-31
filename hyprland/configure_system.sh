#!/usr/bin/env bash

set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$THIS_DIR/../utils.sh"
source "$THIS_DIR/../core/env.sh"

CONFIG_SRC="$THIS_DIR/../.config"
CONFIG_DEST="$USER_HOME/.config"

WALLPAPER_SRC="$THIS_DIR/../assets/wallpapers"
WALLPAPER_DEST="$USER_HOME/wallpapers"

copy_configs() {
    log_info "Copying configuration files to $CONFIG_DEST..."
    if [[ ! -d "$CONFIG_SRC" ]]; then
        log_error "Configuration source $CONFIG_SRC not found."
        exit 1
    fi
    mkdir -p "$CONFIG_DEST"
    cp -r "$CONFIG_SRC"/* "$CONFIG_DEST/"
    chown -R "$CURRENT_USER:$CURRENT_USER" "$CONFIG_DEST"
}

copy_wallpapers() {
    log_info "Copying wallpapers to $WALLPAPER_DEST..."
    if [[ ! -d "$WALLPAPER_SRC" ]]; then
        log_error "Wallpaper source $WALLPAPER_SRC not found."
        exit 1
    fi
    mkdir -p "$WALLPAPER_DEST"
    cp -r "$WALLPAPER_SRC"/* "$WALLPAPER_DEST/"
    chown -R "$CURRENT_USER:$CURRENT_USER" "$WALLPAPER_DEST"
}

enable_sddm() {
    log_info "Enabling SDDM service..."
    systemctl enable sddm.service --now
}

main() {
    log_info "Starting Hyprland configuration..."

    copy_configs
    copy_wallpapers
    enable_sddm

    log_info "✅ Hyprland configuration completed successfully."
}

main

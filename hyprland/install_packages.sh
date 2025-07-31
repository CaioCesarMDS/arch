#!/usr/bin/env bash

set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$THIS_DIR/../utils.sh"
source "$THIS_DIR/../core/env.sh"

log_info "Installing essential packages for Hyprland..."

install_pkgs() {
    local title="$1"; shift
    log_info "Installing: $title"
    pacman -S --noconfirm --needed "$@"
}

install_pkgs "Hyprland and core components" \
    hyprland hypridle hyprlock hyprpolkitagent kitty \
    qt5-wayland qt6-wayland sddm swww xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk

install_pkgs "System utilities" \
    cliphist dolphin swaync waybar wofi wl-clipboard \
    pavucontrol pamixer

install_pkgs "Theming tools" \
    python-pywal nwg-look qt5ct qt6ct kvantum kvantum-qt5

install_pkgs "KDE extras and integration" \
    ark dolphin-plugins ffmpegthumbs gvfs kde-cli-tools \
    kio-admin qt5-imageformats qt5-quickcontrols qt5-quickcontrols2 \
    qt5-graphicaleffects

log_info "✅ All packages were installed successfully."

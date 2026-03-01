#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="$(dirname "$(realpath "$0")")"

source "$SRC_DIR/utils/global_func.sh"

install_common_packages() {
    log_info "Installing essential packages for Hyprland..."

    install_packages "Hyprland and core components" \
        hyprland hypridle hyprlock hyprpicker hyprpolkitagent \
        hyprsunset hyprshot kitty qt5-wayland qt6-wayland sddm swww \
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

    install_packages "System utilities" \
        clapper cliphist brightnessctl discord firefox \
        gnome-keyring nautilus loupe pavucontrol pamixer \
        steam starship swaync waybar wl-clipboard

    install_packages "Audio/Video codecs" \
        ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base \
        gst-plugins-bad gst-libav gstreamer

    install_packages "Fonts" \
        noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
        ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-liberation

    install_packages "Theming tools" \
        gnome-themes-extra nwg-look qt5ct qt6ct qt6-svg \
        qt6-virtualkeyboard qt6-multimedia-ffmpeg kvantum kvantum-qt5

    install_aur_packages "AUR utilities and themes" \
        spotify visual-studio-code-bin gtk-engine-murrine
}

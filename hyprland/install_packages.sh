#!/usr/bin/env bash

set -euo pipefail

scrDir="$(dirname "$(realpath "$0")")"

source "$scrDir/utils/global_func.sh"

DEVICE_TYPE=$(detect_device_type)

install_common_packages() {
    log_info "Installing essential packages for Hyprland..."

    install_packages "Hyprland and core components" \
        hyprland hypridle hyprlock hyprpicker hyprpolkitagent hyprsunset hyprshot \
        kitty qt5-wayland qt6-wayland sddm swww \
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

    install_packages "System utilities" \
        clapper cliphist discord firefox gnome-keyring nautilus loupe \
        pavucontrol pamixer steam starship swaync waybar wofi wl-clipboard

    install_packages "Audio/Video codecs" \
        ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base \
        gst-plugins-bad gst-libav gstreamer

    install_packages "Fonts" \
        noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
        ttf-firacode-nerd ttf-font-awesome ttf-jetbrains-mono \
        ttf-jetbrains-mono-nerd ttf-liberation ttf-meslo-nerd

    install_packages "Theming tools" \
        python-pywal nwg-look qt5ct qt6ct kvantum kvantum-qt5

    install_aur_packages "AUR utilities and themes" \
        python-pywalfox sddm-theme-sugar-candy spotify \
        visual-studio-code-bin wlogout
}

if [[ "$DEVICE_TYPE" == "laptop" ]]; then
    install_common_packages
    install_packages "Hyprland laptop-specific packages" \
        brightnessctl
else
    install_common_packages
    install_packages "Hyprland desktop-specific packages" \
        ddcutil
fi

log_info "✅ All packages were installed successfully."

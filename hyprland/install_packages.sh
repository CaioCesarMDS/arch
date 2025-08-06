#!/usr/bin/env bash

set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$THIS_DIR/../utils.sh"
source "$THIS_DIR/../core/env.sh"

log_info "Installing essential packages for Hyprland..."

install_packages "Hyprland and core components" \
    hyprland hypridle hyprlock hyprpicker hyprpolkitagent hyprsunset hyprshot \
    kitty qt5-wayland qt6-wayland gdm swww \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

install_packages "System utilities" \
    clapper cliphist gnome-keyring nautilus loupe \
    pavucontrol pamixer swaync waybar wofi wl-clipboard 


install_packages "audio/video codecs" \
    ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base \
    gst-plugins-bad gst-libav gstreamer

install_packages "fonts" \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-firacode-nerd ttf-font-awesome ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd ttf-liberation ttf-meslo-nerd

install_packages "Theming tools" \
    python-pywal nwg-look qt5ct qt6ct kvantum kvantum-qt5

log_info "✅ All packages were installed successfully."

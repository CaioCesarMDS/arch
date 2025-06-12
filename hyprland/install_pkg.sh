#!/bin/bash

set -e

# =======================================
# Install essential packages for hyprland
# =======================================
echo "Installing essential packages..."

# ===============================
#         Hyprland Setup
# ===============================
pacman -S --noconfirm --needed \
    hyprland \
    hypridle \
    hyprlock \
    hyprpolkitagent \
    kitty \
    qt5-wayland \
    qt6-wayland \
    sddm \
    swww \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk

yay -S --noconfirm --needed \
    hyprsunset \
    wlogout

pip install pywal

# ===============================
#         System Tools
# ===============================
pacman -S --noconfirm --needed \
    cliphist \
    dolphin \
    swaync \
    waybar \
    rofi-wayland \
    wl-clipboard \
    pavucontrol \
    pamixer 

# ===============================
#         Theming tools
# ===============================
pacman -S --noconfirm --needed \
    python-pywal \
    nwg-look \
    qt5ct \
    qt6ct \
    kvantum \
    kvantum-qt5

# ===============================
#             Extras
# ===============================
pacman -S --noconfirm --needed \
    ark \
    dolphin-plugins \
    ffmpegthumbs \
    gvfs \
    kde-cli-tools \
    kio-admin \
    qt5-imageformats \
    qt5-quickcontrols \
    qt5-quickcontrols2 \
    qt5-graphicaleffects

yay -S --noconfirm --needed \
    libnotify
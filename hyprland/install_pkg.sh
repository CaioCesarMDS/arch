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
    hyprpaper \
    hyprsunset \
    hyprpolkitagent \
    kitty \
    python-pywal \
    qt5-wayland \
    qt6-wayland \
    sddm \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk

# ===============================
#         System Tools
# ===============================
pacman -S --noconfirm --needed \
    cliphist \
    dolphin \
    swaync \
    waybar \
    wofi \
    wl-clipboard

# ===============================
#         Theming tools
# ===============================
pacman -S --noconfirm --needed \
    nwg-look \
    qt5ct \
    qt6ct \
    kvantum \
    kvantum-qt5 \
    qt5-quickcontrols \
    qt5-quickcontrols2 \
    qt5-graphicaleffects 


# ===============================
#             Extras
# ===============================
pacman -S --noconfirm --needed \
    ark \
    ffmpegthumbs \
    kde-cli-tools \
    qt5-imageformats 



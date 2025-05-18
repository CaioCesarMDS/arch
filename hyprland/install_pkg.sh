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
    thunar \
    swaync \
    waybar \
    wofi \
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
    gvfs

yay -S --noconfirm --needed \
    libnotify
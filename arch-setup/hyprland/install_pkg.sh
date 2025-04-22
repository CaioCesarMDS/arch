#!/bin/bash

set -e

# =======================================
# Install essential packages for hyprland
# =======================================
echo "Installing essential packages..."

pacman -S --noconfirm --needed \
  hyprland kitty sddm dunst wireplumber \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  hyprpolkitagent qt5-imageformats ffmpegthumbs kde-cli-tools \
  ffmpegthumbs qt5-wayland qt6-wayland waybar dolphin wofi \
  hyprpaper cliphist wl-clipboard





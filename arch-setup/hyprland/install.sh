#!/bin/zsh

# Update system
echo "Updating the system..."
pacman -Syu --noconfirm

# Install some packages
echo "Installing essential packages..."
pacman -S --noconfirm --needed \
  hyprland kitty sddm dunst wireplumber \
  xdg-desktop-portal-hyprland hyprpolkitagent \
  qt5-wayland qt6-wayland waybar dolphin wofi \
  hyprpaper cliphist wl-clipboard

echo "Enabling SDDM..."
sudo systemctl enable sddm.service --now

echo "Installation is complete! You can now start Hyperland with SDDM."

#!/bin/bash

set -e


# ===============================
#   Copy configuration files
# ===============================
cp -r ./.config "/home/$SUDO_USER/"
chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config"

# ===============================
#   Setup user service
# ===============================
echo "Configuring hyprsunset.timer for the user..."

sudo -u "$SUDO_USER" systemctl --user daemon-reload
sudo -u "$SUDO_USER" systemctl --user enable --now hyprsunset.timer


# ===============================
#   Set wallpaper and pywal
# ===============================
sww img ~/wallpapers/clouds.jpg
wal -i ~/wallpapers/clouds.jpg

# ===============================
#   Enabling SDDM Service
# ===============================
echo "Enabling SDDM..."
sudo systemctl enable sddm.service --now
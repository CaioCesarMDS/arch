#!/bin/zsh

# Update system
echo "Updating the system..."
pacman -Syu --noconfirm

# Install GNOME and essential components
echo "Installing GNOME..."
pacman -S --noconfirm --needed \
    baobab decibels evince gdm gnome-calculator \
    gnome-calendar gnome-characters gnome-clocks \
    gnome-connections gnome-console gnome-control-center \
    gnome-disk-utility gnome-font-viewer gnome-keyring \
    gnome-logs gnome-menus gnome-music gnome-remote-desktop \
    gnome-session gnome-settings-daemon gnome-shell \
    gnome-shell-extensions gnome-software gnome-system-monitor \
    gnome-text-editor grilo-plugins gvfs gvfs-dnssd gvfs-goa \
    gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb gvfs-wsdd \
    loupe malcontent nautilus sushi totem xdg-desktop-portal-gnome


# Enable and start GDM
echo "Enabling and starting GDM..."
systemctl enable --now gdm

echo "GNOME installation complete!"

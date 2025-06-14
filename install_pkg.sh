#!/bin/bash

set -e

echo "Installing essential packages..."

# ===============================
#          System base
# ===============================
pacman -S --noconfirm --needed \
    linux \
    linux-firmware \
    linux-headers \
    base \
    base-devel \
    grub \
    efibootmgr \
    os-prober \
    fuse3 \
    intel-ucode \
    xdg-user-dirs \
    pipewire \
    pipewire-pulse \
    networkmanager

# ===============================
#          Utils tools
# ===============================
pacman -S --noconfirm --needed \
    blueman \
    bluez \
    bluez-utils \
    btop \
    curl \
    fastfetch \
    git \
    imagemagick \
    inetutils \
    jq \
    languagetool \
    man-db \
    man-pages \
    nano \
    openssh \
    p7zip \
    pacman-contrib \
    procps-ng \
    sassc \
    ufw \
    unzip \
    usbutils \
    vim \
    wget \
    zip \
    zsh \
    wireplumber

# ===============================
#   Codecs for audio and video
# ===============================
pacman -S --noconfirm --needed \
    ffmpeg \
    gst-plugins-ugly \
    gst-plugins-good \
    gst-plugins-base \
    gst-plugins-bad \
    gst-libav \
    gstreamer \
    mpv

# ===============================
#            Fonts
# ===============================
pacman -S --noconfirm --needed \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    noto-fonts-extra \
    ttf-bitstream-vera \
    ttf-dejavu \
    ttf-firacode-nerd \
    ttf-font-awesome \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    ttf-liberation \
    ttf-meslo-nerd \
    ttf-nerd-fonts-symbols

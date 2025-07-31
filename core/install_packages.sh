#!/usr/bin/env bash

set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$THIS_DIR/../utils.sh"
source "$THIS_DIR/../core/env.sh"

log_info "Installing essential packages for Arch"

install_packages() {
    local category="$1"
    shift
    local packages=("$@")

    log_info "Installing ${category} packages..."
    pacman -S --noconfirm --needed "${packages[@]}"
}

install_packages "system base" \
    base base-devel efibootmgr grub fuse3 intel-ucode linux linux-firmware \
    linux-headers networkmanager pipewire pipewire-pulse os-prober \
    xdg-user-dirs wireplumber

install_packages "utility tools and dependencies" \
    blueman bluez bluez-utils btop curl fastfetch git imagemagick \
    inetutils jq languagetool man-db man-pages nano openssh openssl p7zip \
    pacman-contrib procps-ng sassc tcl tk tree ufw unzip usbutils \
    neovim xz wget zip zlib zsh

install_packages "audio/video codecs" \
    ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base \
    gst-plugins-bad gst-libav gstreamer mpv

install_packages "fonts" \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-bitstream-vera ttf-dejavu ttf-firacode-nerd ttf-font-awesome \
    ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-liberation \
    ttf-meslo-nerd ttf-nerd-fonts-symbols

log_info "✅ All packages were installed successfully."

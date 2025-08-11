#!/usr/bin/env bash

set -euo pipefail

source "$scrDir/utils/global_func.sh"

log_info "Installing essential packages for Arch"

install_packages "system base" \
    base base-devel efibootmgr grub fuse3 intel-ucode linux linux-firmware \
    linux-headers make networkmanager pipewire pipewire-pulse os-prober \
    xdg-user-dirs wireplumber

install_packages "utility tools and dependencies" \
    blueman bluez bluez-utils bat btop curl eza fastfetch fzf git imagemagick \
    inetutils jq languagetool man-db man-pages nano openssh openssl p7zip \
    pacman-contrib procps-ng sassc shfmt tcl tk tree ufw unzip usbutils \
    neovim xz wget zip zoxide zlib zsh

log_info "✅ All packages were installed successfully."

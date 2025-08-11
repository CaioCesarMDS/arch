#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="$(dirname "$(realpath "$0")")"

source "$SRC_DIR/utils/global_func.sh"
source "$SRC_DIR/core/env.sh"

install_yay() {
    if ! command -v yay &>/dev/null; then
        log_info "Installing yay (AUR helper)..."
        local yay_dir="/opt/yay"
        if [ ! -d "$yay_dir" ]; then
            git clone https://aur.archlinux.org/yay.git "$yay_dir"
            chown -R "$CURRENT_USER:$CURRENT_USER" "$yay_dir"
        fi
        cd "$yay_dir"
        sudo -u "$CURRENT_USER" makepkg -si --noconfirm
    else
        log_info "yay already installed"
    fi
}

install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        log_info "Installing flatpak"
        sudo pacman -S --noconfirm --needed flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        log_info "Flatpak already installed"
    fi
}

main() {
    log_info "Installing extra tools."

    install_yay
    install_flatpak

    log_info "Extra tools installation completed successfully."
}

main

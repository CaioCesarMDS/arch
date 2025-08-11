#!/usr/bin/env bash

set -euo pipefail

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

detect_device_type() {
    if ls /sys/class/power_supply/ | grep -qi "^BAT"; then
        echo "laptop"
    else
        echo "desktop"
    fi
}
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

run_script() {
    local script="$1"
    if [[ -f "$script" ]]; then
        log_info "Running $script"
        source "$script"
    else
        log_error "$script not found!"
        exit 1
    fi
}

prompt_reboot() {
    log_info "✅ Installation completed successfully."
    read -rp "Reboot now? [y/N]: " ans
    if [[ "$ans" =~ ^([Yy])$ ]]; then
        reboot
    else
        log_info "Remember to reboot manually later."
    fi
}

install_packages() {
    local title="$1"
    shift
    log_info "Installing: $title"
    pacman -S --noconfirm --needed "$@"
}

install_aur_packages() {
    local title="$1"
    shift
    log_info "Installing from AUR: $title"
    sudo -u "$SUDO_USER" yay -S --noconfirm --needed "$@"
}

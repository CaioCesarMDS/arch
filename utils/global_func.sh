#!/usr/bin/env bash

set -euo pipefail

log_info() {
    echo "[INFO] $*"
}

log_warn() {
    echo "[WARN] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Detect the device type (laptop or desktop)
detect_device_type() {
    if ls /sys/class/power_supply/ | grep -qi "^BAT"; then
        echo "laptop"
    else
        echo "desktop"
    fi
}

# Check if the script is run as root
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

update_system() {
    log_info "Updating the system..."
    pacman -Syu --noconfirm
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

# Detect the appropriate tar flag based on the file extension
detect_tar_flag() {
    local file="$1"
    case "$file" in
    *.tar.gz | *.tgz) echo "-z" ;;
    *.tar.xz | *.txz) echo "-J" ;;
    *.tar.bz2 | *.tbz2) echo "-j" ;;
    *)

        if command -v file >/dev/null 2>&1; then
            mime=$(file -b --mime-type "$file" 2>/dev/null || true)
            case "$mime" in
            application/x-xz) echo "-J" ;;
            application/gzip) echo "-z" ;;
            application/x-bzip2) echo "-j" ;;
            *) echo "" ;;
            esac
        else
            echo ""
        fi
        ;;
    esac
}

# Get CPU Family
cpu_info() {
    if grep -iq 'intel' /proc/cpuinfo; then
        echo "intel"
    elif grep -iq 'amd' /proc/cpuinfo; then
        echo "amd"
    else
        echo "unknown"
    fi
}

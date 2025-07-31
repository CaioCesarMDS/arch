#!/usr/bin/env bash

set -euo pipefail

add_line_if_missing() {
    local file="$1"
    local line="$2"
    if ! grep -qxF "$line" "$file"; then
        echo "$line" >>"$file"
    fi
}

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
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
    log_info "✅ Installation completed successfully".
    read -rp "Reboot now? [y/N]: " ans
    if [[ "$ans" =~ ^([Yy])$ ]]; then
        reboot
    else
        log_info "Remember to reboot manually later."
    fi
}



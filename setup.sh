#!/usr/bin/env bash

set -euo pipefail

source ./utils.sh

load_env() {
    local env_file="./core/env.sh"
    if [[ -f "$env_file" ]]; then
        source "$env_file"
    else
        log_error "Environment file $env_file not found!"
        exit 1
    fi

    if [[ -z "${CURRENT_USER:-}" || -z "${USER_HOME:-}" ]]; then
        log_error "CURRENT_USER or USER_HOME is not set in $env_file."
        exit 1
    fi
}

update_system() {
    log_info "Updating the system..."
    pacman -Syu --noconfirm
}

main() {
    echo -e "\n======================================"
    echo "  🚀 Starting Arch Linux Setup + Hyprland"
    echo -e "========================================\n"

    check_root
    load_env
    update_system

    run_script "./core/install_packages.sh"
    run_script "./core/configure_system.sh"
    run_script "./core/extras_tools.sh"

    prompt_reboot
}

main

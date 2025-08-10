#!/usr/bin/env bash

set -euo pipefail

export scrDir="$(dirname "$(realpath "$0")")"

source "$scrDir/utils/global_func.sh"

update_system() {
    log_info "Updating the system..."
    pacman -Syu --noconfirm
}

main() {
    echo -e "\n======================================"
    echo "  🚀 Starting Arch Linux Setup + Hyprland"
    echo -e "========================================\n"

    check_root
    update_system

    run_script "./core/install_packages.sh"
    run_script "./core/configure_system.sh"
    run_script "./core/extras_tools.sh"

    run_script "./hyprland/install_packages.sh"
    run_script "./hyprland/configure_system.sh"

    prompt_reboot
}

main

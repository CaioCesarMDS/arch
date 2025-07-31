#!/usr/bin/env bash

set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$THIS_DIR/../utils.sh"
source "$THIS_DIR/.env.sh"

install_grub() {
    log_info "Installing GRUB bootloader..."

    EFI_DIR="/boot/efi"
    if [[ ! -d "$EFI_DIR" ]]; then
        log_error "EFI directory $EFI_DIR not found."
        exit 1
    fi

    if [[ ! -f "$EFI_DIR/EFI/GRUB/grubx64.efi" ]]; then
        grub-install --target=x86_64-efi --efi-directory="$EFI_DIR" --bootloader-id=GRUB --recheck
    else
        log_info "GRUB already installed, skipping."
    fi
}

configure_grub() {
    log_info "Configuring GRUB to detect other operating systems..."

    GRUB_FILE="/etc/default/grub"
    if [[ ! -f "$GRUB_FILE" ]]; then
        log_error "$GRUB_FILE not found."
        exit 1
    fi

    if grep -q "^#*GRUB_DISABLE_OS_PROBER=" "$GRUB_FILE"; then
        sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_FILE"
    else
        echo "GRUB_DISABLE_OS_PROBER=false" >>"$GRUB_FILE"
    fi

    grub-mkconfig -o /boot/grub/grub.cfg
}

enable_services() {
    log_info "Enabling essential services..."
    systemctl enable NetworkManager
    systemctl start NetworkManager
    systemctl enable paccache.timer
    systemctl enable ufw
}

configure_pacman() {
    log_info "Configuring pacman for parallel downloads..."

    PACMAN_FILE="/etc/pacman.conf"
    if [[ ! -f "$PACMAN_FILE" ]]; then
        log_error "$PACMAN_FILE not found."
        exit 1
    fi

    if grep -q "^[#]*ParallelDownloads" "$PACMAN_FILE"; then
        sed -i 's/^[#]*ParallelDownloads.*/ParallelDownloads = 10/' "$PACMAN_FILE"
    else
        sed -i '/^\[options\]/a ParallelDownloads = 10' "$PACMAN_FILE"
    fi
}

configure_sudo() {
    log_info "Configuring sudoers for wheel group..."
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
}

create_user_dirs() {
    log_info "Creating default user directories for $CURRENT_USER..."
    sudo -u "$CURRENT_USER" xdg-user-dirs-update
}

set_default_shell() {
    log_info "Setting zsh as default shell for $CURRENT_USER..."
    if ! command -v zsh &>/dev/null; then
        log_error "zsh not installed."
        exit 1
    fi
    chsh -s "$(which zsh)" "$CURRENT_USER"
}

main() {
    log_info "Configuring the system."

    install_grub
    configure_grub
    enable_services
    configure_pacman
    configure_sudo
    create_user_dirs
    set_default_shell

    log_info "System configuration completed successfully."
}

main

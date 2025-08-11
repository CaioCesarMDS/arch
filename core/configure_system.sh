#!/usr/bin/env bash

set -euo pipefail

source "$scrDir/utils/global_func.sh"
source "$scrDir/core/env.sh"

install_grub() {
    log_info "Installing GRUB bootloader..."

    EFI_DIR="/boot/efi"
    if [[ ! -d "$EFI_DIR" ]]; then
        log_error "EFI directory $EFI_DIR not found."
        exit 1
    fi

    if [[ ! -f "$EFI_DIR/EFI/GRUB/grubx64.efi" ]]; then
        grub-install --target=x86_64-efi --efi-directory="$EFI_DIR" --bootloader-id=ARCH --recheck
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

    if [[ -x "$(command -v os-prober)" ]]; then
        if grep -q "^#*GRUB_DISABLE_OS_PROBER=" "$GRUB_FILE"; then
            sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_FILE"
        else
            echo "GRUB_DISABLE_OS_PROBER=false" >>"$GRUB_FILE"
        fi
    else
        log_info "os-prober not found. Skipping multi-OS detection config."
    fi

    grub-mkconfig -o /boot/grub/grub.cfg
}

install_grub_theme() {
    grub_theme="$scrDir/assets/grub/Grub_Retroboot.tar.gz"
    log_info "Installing GRUB theme..."

    if [[ ! -f "$grub_theme" ]]; then
        log_error "Grub theme not found: $grub_theme"
        exit 1
    fi

    mkdir -p /usr/share/grub/themes

    top_entry=$(tar -tzf "$grub_theme" 2>/dev/null | sed -n '1p' || true)
    theme_dir_name=$(printf '%s' "$top_entry" | cut -d'/' -f1)

    if ! tar -xzf "$grub_theme" -C /usr/share/grub/themes/; then
        log_error "Failed to extract $grub_theme"
        exit 1
    fi

    if [[ -n "$theme_dir_name" && -d "/usr/share/grub/themes/$theme_dir_name" ]]; then
        target_dir="/usr/share/grub/themes/$theme_dir_name"
    else
        possible=$(find /usr/share/grub/themes -maxdepth 2 -type f -name theme.txt -printf '%h\n' 2>/dev/null | head -n1 || true)
        if [[ -n "$possible" ]]; then
            target_dir="$possible"
        else
            log_error "Not possible to identify theme directory (looking for theme.txt)."
            exit 1
        fi
    fi

    if [[ ! -f "$target_dir/theme.txt" ]]; then
        log_error "theme.txt not found in: $target_dir"
        exit 1
    fi

    log_info "Theme installed in: $target_dir"

    cp /etc/default/grub /etc/default/grub.bak."$(date +%s)"
    log_info "Backup of /etc/default/grub created."

    if grep -q '^GRUB_DEFAULT=' /etc/default/grub; then
        sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
    else
        echo 'GRUB_DEFAULT=saved' | tee -a /etc/default/grub >/dev/null
    fi

    if grep -q '^GRUB_GFXMODE=' /etc/default/grub; then
        sed -i 's/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1280x1024x32,auto/' /etc/default/grub
    else
        echo 'GRUB_GFXMODE=1280x1024x32,auto' | tee -a /etc/default/grub >/dev/null
    fi

    grub_theme_line="GRUB_THEME=\"${target_dir}/theme.txt\""
    if grep -q '^GRUB_THEME=' /etc/default/grub; then
        sed -i "s|^GRUB_THEME=.*|${grub_theme_line}|" /etc/default/grub
    else
        echo "${grub_theme_line}" | tee -a /etc/default/grub >/dev/null
    fi

    if grep -q '^GRUB_SAVEDEFAULT=' /etc/default/grub; then
        sed -i 's/^GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/' /etc/default/grub
    else
        echo 'GRUB_SAVEDEFAULT=true' | tee -a /etc/default/grub >/dev/null
    fi

    log_info "File /etc/default/grub updated. Regenerating grub.cfg..."

    if ! grub-mkconfig -o /boot/grub/grub.cfg; then
        log_error "Failed to generate /boot/grub/grub.cfg"
        return 1
    fi

    log_info "GRUB updated with theme: $target_dir"
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
    install_grub_theme
    enable_services
    configure_pacman
    configure_sudo
    create_user_dirs
    set_default_shell

    log_info "System configuration completed successfully."
}

main

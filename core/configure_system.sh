#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="$(dirname "$(realpath "$0")")"

source "$SRC_DIR/utils/global_func.sh"
source "$SRC_DIR/core/env.sh"

install_grub() {
    log_info "Installing GRUB bootloader..."

    local efi_dir="/boot/efi"
    if [[ ! -d "$efi_dir" ]]; then
        log_error "$efi_dir not found."
        exit 1
    fi

    if [[ ! -f "$efi_dir/EFI/GRUB/grubx64.efi" ]]; then
        grub-install --target=x86_64-efi --efi-directory="$efi_dir" --bootloader-id=ARCH --recheck
    else
        log_info "GRUB already installed, skipping."
    fi
}

configure_grub() {
    log_info "Configuring GRUB to detect other operating systems..."

    local grub_file="/etc/default/grub"
    if [[ ! -f "$grub_file" ]]; then
        log_error "$grub_file not found."
        exit 1
    fi

    if [[ -x "$(command -v os-prober)" ]]; then
        if grep -q "^#*GRUB_DISABLE_OS_PROBER=" "$grub_file"; then
            sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$grub_file"
        else
            echo "GRUB_DISABLE_OS_PROBER=false" >>"$grub_file"
        fi
    else
        log_info "OS-Prober not found. Skipping multi-OS detection config."
    fi

    grub-mkconfig -o /boot/grub/grub.cfg
}

install_grub_theme() {
    log_info "Installing GRUB theme..."

    # Define variables
    local grub_theme_dir="/usr/share/grub/themes"
    local grub_cfg="/boot/grub/grub.cfg"
    local grub_default="/etc/default/grub"
    local default_gfxmode="1920x1080x32,auto"
    local themes_available=("$SRC_DIR"/assets/grub/*.tar.*)

    # Check if any themes are available
    if ((${#themes_available[@]} == 0)); then
        log_error "No GRUB themes found in $SRC_DIR/assets/grub/"
        exit 1
    fi

    # Create menu items
    local menu_items=()
    for file in "${themes_available[@]}"; do
        filename=$(basename "$file")
        filename="${filename%.tar.*}"
        menu_items+=("$filename")
    done
    menu_items+=("None (do not install theme)")

    # Prompt user for theme selection
    echo "Choose a theme to install:"
    local choice
    select choice in "${menu_items[@]}"; do
        if [[ -n "$choice" ]]; then
            break
        else
            echo "Invalid option."
        fi
    done

    # Check if user selected a theme
    if [[ "$choice" == "None (do not install theme)" ]]; then
        log_info "GRUB theme installation skipped."
        return
    fi

    # Identify the theme file
    local chosen_theme="${themes_available[$((REPLY - 1))]}"

    if [[ ! -f "$chosen_theme" ]]; then
        log_error "Theme file not found: $chosen_theme"
        exit 1
    fi

    mkdir -p "$grub_theme_dir"

    # Detect the tar command flags
    local tar_flags=($(detect_tar_flag "$chosen_theme"))

    # Identify the top entry in the theme archive
    local top_entry=$(tar $tar_flags -tf "$chosen_theme" 2>/dev/null | sed -n '1p' || true)
    local theme_dir_name=$(printf '%s' "$top_entry" | cut -d'/' -f1)

    rm -rf "$grub_theme_dir/"*

    # Extract the theme files
    if ! tar "${tar_flags[@]}" -xf "$chosen_theme" -C "$grub_theme_dir"; then
        log_error "Failed to extract $chosen_theme"
        exit 1
    fi

    # Identify the theme directory
    local target_dir="$grub_theme_dir/$theme_dir_name"

    if [[ ! -f "$target_dir/theme.txt" ]]; then
        log_error "theme.txt not found in: $target_dir"
        exit 1
    fi

    # Backup current GRUB configuration
    cp "$grub_default" "$grub_default.bak.$(date +%s)"
    log_info "Backup of $grub_default created."

    # Define option in $grub_default
    {
        grep -q '^GRUB_DEFAULT=' "$grub_default" &&
            sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' "$grub_default" ||
            echo 'GRUB_DEFAULT=saved' >>"$grub_default"

        grep -q '^GRUB_GFXMODE=' "$grub_default" &&
            sed -i "s|^GRUB_GFXMODE=.*|GRUB_GFXMODE=$default_gfxmode|" "$grub_default" ||
            echo "GRUB_GFXMODE=$default_gfxmode" >>"$grub_default"

        grep -q '^GRUB_THEME=' "$grub_default" &&
            sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$target_dir/theme.txt\"|" "$grub_default" ||
            echo "GRUB_THEME=\"$target_dir/theme.txt\"" >>"$grub_default"

        grep -q '^GRUB_SAVEDEFAULT=' "$grub_default" &&
            sed -i 's/^GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/' "$grub_default" ||
            echo 'GRUB_SAVEDEFAULT=true' >>"$grub_default"
    }

    # Regenerate GRUB configuration
    if ! grub-mkconfig -o "$grub_cfg"; then
        log_error "Failed to generate $grub_cfg"
        exit 1
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

    local pacman_file="/etc/pacman.conf"
    if [[ ! -f "$pacman_file" ]]; then
        log_error "$pacman_file not found."
        exit 1
    fi

    if grep -q "^[#]*ParallelDownloads" "$pacman_file"; then
        sed -i 's/^[#]*ParallelDownloads.*/ParallelDownloads = 10/' "$pacman_file"
    else
        sed -i '/^\[options\]/a ParallelDownloads = 10' "$pacman_file"
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

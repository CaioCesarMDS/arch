#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="$(dirname "$(realpath "$0")")"

source "$SRC_DIR/utils/global_func.sh"
source "$SRC_DIR/utils/monitor_utils.sh"
source "$SRC_DIR/core/env.sh"

clone_or_update() {
  local url="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    log_info "Updating $dest"
    git -C "$dest" pull --ff-only || true
  else
    log_info "Cloning $url -> $dest"
    rm -rf "$dest"
    git clone --depth 1 "$url" "$dest"
  fi
}

copy_configs() {
    log_info "Copying configs"

    local config_src="$SRC_DIR/.config"
    local config_dest="$USER_HOME/.config"

    mkdir -p "$config_dest"
    cp -r "$config_src/"* "$config_dest/"

    replace_monitor_line "$config_dest/hypr/hyprland.conf"
    chown -R "$CURRENT_USER":"$CURRENT_USER" "$config_dest"
}

copy_wallpapers() {
    local wallpaper_src="$SRC_DIR/assets/wallpapers"
    local wallpaper_dest="$USER_HOME/Wallpapers"

    if [[ ! -d "$wallpaper_src" ]]; then
        log_error "Wallpaper directory not found."
        exit 1
    fi

    mkdir -p "$wallpaper_dest"
    cp -r "$wallpaper_src/"* "$wallpaper_dest/"
    chown -R "$CURRENT_USER":"$CURRENT_USER" "$wallpaper_dest"
}

set_sddm_theme() {
    log_info "Installing SDDM theme..."

    local repo_url="https://github.com/keyitdev/sddm-astronaut-theme.git"
    local repo_dir="/usr/share/sddm/themes/sddm-astronaut-theme"
    local metadata="${repo_dir}/metadata.desktop"

    clone_or_update "$repo_url" "$repo_dir"

    # Copy fonts (if exist) and refresh font cache
    if [[ -d "${repo_dir}/Fonts" ]]; then
        cp -r "${repo_dir}/Fonts/"* /usr/share/fonts/ 2>/dev/null || true
        fc-cache -f >/dev/null 2>&1 || true
    fi

    # Find available theme config files inside Themes/
    if [[ ! -d "${repo_dir}/Themes" ]]; then
        log_error "Themes directory not found in $repo_dir"
        return 1
    fi

    mapfile -t available_themes < <(find "${repo_dir}/Themes" -maxdepth 1 -type f -name '*.conf' -printf '%f\n' | sort)
    if [[ ${#available_themes[@]} -eq 0 ]]; then
        log_error "No theme config files (*.conf) found under ${repo_dir}/Themes"
        return 1
    fi

    # Interactive selection
    echo "Select SDDM theme to install:"
    PS3="Enter number (or Ctrl+C to cancel): "
    select chosen_file in "${available_themes[@]}"; do
        if [[ -n "$chosen_file" ]]; then
        log_info "You selected: $chosen_file"
        break
        else
        echo "Invalid choice. Try again."
        fi
    done

    # Update metadata.desktop -> ConfigFile=Themes/<chosen_file>
    if [[ -f "$metadata" ]]; then
        cp "$metadata" "${metadata}.bak" 2>/dev/null || true
        if grep -q '^ConfigFile=' "$metadata"; then
        sed -i "s|^ConfigFile=.*|ConfigFile=Themes/${chosen_file}|" "$metadata"
        else
        echo "ConfigFile=Themes/${chosen_file}" | tee -a "$metadata" >/dev/null
        fi
        log_info "Updated metadata.desktop to use Themes/${chosen_file}"
    else
        log_error "Metadata file not found at $metadata"
    fi

    # Enable the theme globally by writing a small conf inside /etc/sddm.conf.d/
    mkdir -p /etc/sddm.conf.d
    echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | tee /etc/sddm.conf.d/theme.conf >/dev/null

    # Ensure virtual keyboard is configured for the greeter
    mkdir -p /etc/sddm.conf.d
    echo -e "[General]\nInputMethod=qtvirtualkeyboard" | tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

    # Optional: give user a command to preview
    log_info "SDDM theme installed/updated. Selected config: ${chosen_file}"
}

enable_sddm() {
    log_info "Enabling SDDM service..."
    systemctl enable sddm.service
}

main() {
    log_info "Starting Hyprland configuration..."

    setup_terminal
    copy_configs
    copy_wallpapers
    set_sddm_theme
    enable_sddm

    log_info "✅ Hyprland configuration completed successfully."
}

main

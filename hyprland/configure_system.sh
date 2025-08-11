#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="$(dirname "$(realpath "$0")")"

source "$SRC_DIR/utils/global_func.sh"
source "$SRC_DIR/utils/monitor_utils.sh"
source "$SRC_DIR/core/env.sh"

CONFIG_SRC="$SRC_DIR/.config"
CONFIG_DEST="$USER_HOME/.config"

WALLPAPER_SRC="$SRC_DIR/assets/Wallpapers"
WALLPAPER_DEST="$USER_HOME/Wallpapers"
ZSHRC="$USER_HOME/.zshrc"

DEVICE_TYPE=$(detect_device_type)

setup_terminal() {
    log_info "Configuring terminal..."

    if [[ -f "$ZSHRC" ]]; then
        cp "$ZSHRC" "$USER_HOME/.zshrc.bak"
    else
        touch "$ZSHRC"
    fi

    cat >"$ZSHRC" <<'EOF'
            export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

            # ------------------------
            # Zinit (Plugin Manager)
            # ------------------------
            ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
            [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
            [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
            source "${ZINIT_HOME}/zinit.zsh"

            # ------------------------
            # Plugins and Snippets
            # ------------------------
            zinit light zsh-users/zsh-autosuggestions
            zinit light zsh-users/zsh-completions
            zinit light zsh-users/zsh-syntax-highlighting

            zinit light Aloxaf/fzf-tab

            zinit snippet OMZP::git
            zinit snippet OMZP::sudo
            zinit snippet OMZP::archlinux

            # ------------------------
            # Plugins Configuration
            # ------------------------
            HISTSIZE=10000
            HISTFILE="$HOME/.zsh_history"
            SAVEHIST=HISTSIZE
            HISTDUP=erase
            setopt append_history
            setopt share_history
            setopt hist_ignore_all_dups
            setopt hist_ignore_dups
            setopt hist_save_no_dups
            setopt hist_ignore_space
            setopt hist_find_no_dups

            # -------------------------
            # Completion Fix & Style
            # -------------------------
            if [ ! -f ~/.zcompdump ] || grep -q "_complete" ~/.zcompdump 2>/dev/null; then
                rm -f ~/.zcompdump*
            fi
            autoload -U compinit && compinit -C

            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
            zstyle ':completion:*' menu no
            zstyle ':fzf-tab:completion:cd:*' fzf-preview use-cache 'ls --color $realpath'

            # Pywal (terminal colors)
            (cat ~/.cache/wal/sequences &)
            source ~/.cache/wal/colors-tty.sh

            # Starship prompt
            eval "$(starship init zsh)"

            # Set up zoxide
            eval "$(zoxide init zsh)"

            # Set up fzf
            source <(fzf --zsh)

            export FZF_DEFAULT_OPTS="
                --height 40%
                --layout=reverse
                --border
                --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
                --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
                --color=info:#7dcfff,prompt:#7aa2f7,pointer:#f7768e
                --color=marker:#9ece6a,spinner:#9ece6a,header:#bb9af7
            "

            export FZF_CTRL_R_OPTS="--style full"

            export FZF_CTRL_T_OPTS="
                --style full
                --walker-skip .git,node_modules,target
                --preview 'bat -n --color=always {}'
                --bind 'ctrl-/:change-preview-window(down|hidden|)'
            "

            # Update System Packages and Tools
            dev-update() {
                echo "🛠️ Updating system tools..."
                sudo pacman -Syu --noconfirm
                yay -Syu --noconfirm
                zinit self-update && zinit update --all
                echo "🎉 Everything's is up to date!"
            }

            # ------------------------
            # Aliases
            # ------------------------
            alias l="ls -la"
            alias ls="eza --icons=always --color=always --long --git --no-filesize --no-time --no-user --no-permissions"
            alias cd="z"
EOF
}

copy_configs() {
    log_info "Copying configs to $CONFIG_DEST..."

    mkdir -p "$CONFIG_DEST"
    cp -r "$CONFIG_SRC/"* "$CONFIG_DEST/"

    replace_monitor_line "$CONFIG_DEST/hypr/hyprland.conf"

    if [[ "$DEVICE_TYPE" == "laptop" ]]; then
        convert_ddcutil_to_brightnessctl "$CONFIG_DEST/hypr/hypridle.conf"

        [[ -d "$CONFIG_SRC/waybar/laptop" ]] && cp -r "$CONFIG_SRC/waybar/laptop/"* "$CONFIG_DEST/waybar/"
        [[ -d "$CONFIG_SRC/swaync/laptop" ]] && cp -r "$CONFIG_SRC/swaync/laptop/"* "$CONFIG_DEST/swaync/"
    else
        rm -rf "$CONFIG_DEST/waybar/laptop" "$CONFIG_DEST/swaync/laptop"
    fi

    chown -R "$CURRENT_USER":"$CURRENT_USER" "$CONFIG_DEST"
}

copy_wallpapers() {
    log_info "Copying wallpapers to $WALLPAPER_DEST..."

    if [[ ! -d "$WALLPAPER_SRC" ]]; then
        log_error "Wallpaper directory not found."
        exit 1
    fi

    mkdir -p "$WALLPAPER_DEST"
    cp -r "$WALLPAPER_SRC/"* "$WALLPAPER_DEST/"
    chown -R "$CURRENT_USER":"$CURRENT_USER" "$WALLPAPER_DEST"
}

set_sddm_theme() {
    log_info "Configuring SDDM theme..."

    local sddm_conf="/etc/sddm.conf"
    local sddm_backgrounds_dir="/usr/share/sddm/themes/Sugar-Candy/Backgrounds"
    local image_path="$USER_HOME/Wallpapers/active_wallpaper/active.jpg"
    local image_name="active.jpg"
    local theme_conf="/usr/share/sddm/themes/Sugar-Candy/theme.conf"

    # Backup sddm.conf
    if [[ -f "$sddm_conf" ]]; then
        cp "$sddm_conf" "${sddm_conf}.bak"
    fi

    if [[ ! -f "$sddm_conf" ]] || ! grep -q '^\[Theme\]' "$sddm_conf"; then
        {
            echo ""
            echo "[Theme]"
            echo "Current=Sugar-Candy"
        } >>"$sddm_conf"
    else
        if grep -q '^Current=' "$sddm_conf"; then
            sed -i 's/^Current=.*/Current=Sugar-Candy/' "$sddm_conf"
        else
            sed -i '/^\[Theme\]/a Current=Sugar-Candy' "$sddm_conf"
        fi
    fi

    mkdir -p "$sddm_backgrounds_dir"
    cp "$image_path" "$sddm_backgrounds_dir/"

    if [[ -f "$theme_conf" ]]; then
        if grep -q '^Background=' "$theme_conf"; then
            sed -i "s|^Background=.*|Background=\"Backgrounds/$image_name\"|" "$theme_conf"
        else
            echo "Background=\"Backgrounds/$image_name\"" >>"$theme_conf"
        fi
    else
        log_error "File $theme_conf not found."
        exit 1
    fi

    chown -R "$CURRENT_USER":"$CURRENT_USER" "$sddm_backgrounds_dir"

    log_info "SDDM Theme configured successfully."
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

#!/usr/bin/env bash

set -euo pipefail

source "$scrDir/utils/global_func.sh"
source "$scrDir/core/env.sh"

install_yay() {
    if ! command -v yay &>/dev/null; then
        log_info "Installing yay (AUR helper)..."
        local YAY_DIR="/opt/yay"
        if [ ! -d "$YAY_DIR" ]; then
            git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
            chown -R "$CURRENT_USER:$CURRENT_USER" "$YAY_DIR"
        fi
        cd "$YAY_DIR"
        sudo -u "$CURRENT_USER" makepkg -si --noconfirm
    else
        log_info "yay already installed"
    fi
}

install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        log_info "Installing flatpak"
        sudo pacman -S --noconfirm --needed flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        log_info "Flatpak already installed"
    fi
}

setup_terminal() {
    log_info "Configuring terminal..."

    ZSHRC="$USER_HOME/.zshrc"

    if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        sudo -u "$CURRENT_USER" bash -c "export CHSH=no RUNZSH=no; cd $USER_HOME && sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""

        sudo -u "$CURRENT_USER" git clone https://github.com/zsh-users/zsh-completions "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-completions"
        sudo -u "$CURRENT_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        sudo -u "$CURRENT_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

        sudo pacman -S --noconfirm --needed starship

        if grep -q '^plugins=' "$ZSHRC"; then
            sed -i '/^plugins=/c\plugins=(git zsh-completions zsh-syntax-highlighting zsh-autosuggestions)' "$ZSHRC"
        else
            echo 'plugins=(git zsh-completions zsh-syntax-highlighting zsh-autosuggestions)' >>"$ZSHRC"
        fi

        add_line_if_missing "$ZSHRC" 'export PATH="/usr/bin:$HOME/.local/bin:$PATH"'
        add_line_if_missing "$ZSHRC" ''
        add_line_if_missing "$ZSHRC" 'eval "$(starship init zsh)"'
        add_line_if_missing "$ZSHRC" ''
    else
        log_info "Oh My Zsh already installed"
    fi
}

main() {
    log_info "Installing extra tools."

    install_yay
    install_flatpak
    setup_terminal

    log_info "Extra tools installation completed successfully."
}

main

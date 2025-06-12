#!/bin/bash

set -e

if [[ -z "$CURRENT_USER" || -z "$USER_HOME" ]]; then
  if [ -f ./global.env ]; then
    source ./global.env
  else
    echo "Error: CURRENT_USER not set and global.env not found."
    exit 1
  fi
fi

if [ -z "$CURRENT_USER" ]; then
  echo "Error: CURRENT_USER is still not defined after sourcing global.env."
  exit 1
fi

source ./functions.sh

# ===============================
#       Environment Variables
# ===============================
ASDF_DIR="$USER_HOME/.asdf"
ZSHRC="$USER_HOME/.zshrc"
NODE_VERSION="22.14.0"
PYTHON_VERSION="3.12.10"

# ===============================
#       yay Installation
# ===============================
if ! command -v yay &>/dev/null; then
  echo "Installing yay (AUR helper)..."

  YAY_DIR="/opt/yay"
  if [ ! -d "$YAY_DIR" ]; then
    git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
    chown -R "$CURRENT_USER:$CURRENT_USER" "$YAY_DIR"
  fi

  cd "$YAY_DIR"
  sudo -u "$CURRENT_USER" makepkg -si --noconfirm
else
  echo "yay already installed"
fi

# ===============================
#       Flatpak Installation
# ===============================
if ! command -v flatpak &>/dev/null; then
  echo "Installing flatpak"

  sudo pacman -S --noconfirm --needed flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
  echo "Flatpak already installed"
fi

# ===============================
#       Terminal Configuration
# ===============================
echo "Configuring terminal..."

if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sudo -u "$CURRENT_USER" bash -c "export CHSH=no RUNZSH=no; cd $USER_HOME && sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""

  # Install extras plugins
  git clone https://github.com/zsh-users/zsh-completions "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-completions"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

  # Install Zoxide
  sudo -u "$CURRENT_USER" bash -c "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"

  # Install FZF
  if [ ! -d "$USER_HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$USER_HOME/.fzf"
    bash "$USER_HOME/.fzf/install" --all
  else
    echo "FZF already installed"
  fi

  # Install Starship
  sudo pacman -S --noconfirm --needed starship

  # Set plugins
  if grep -q '^plugins=' "$ZSHRC"; then
    sed -i '/^plugins=/c\plugins=(git zsh-completions zsh-syntax-highlighting zsh-autosuggestions)' "$ZSHRC"
  else
    echo 'plugins=(git zsh-completions zsh-syntax-highlighting zsh-autosuggestions)' >>"$ZSHRC"
  fi

  # Configure .zshrc
  add_line_if_missing 'export PATH="/usr/bin:$HOME/.local/bin:$PATH"'
  echo '' >>"$ZSHRC"
  add_line_if_missing 'eval "$(starship init zsh)"'
  add_line_if_missing 'eval "$(zoxide init zsh)"'
  echo '' >>"$ZSHRC"
  add_line_if_missing '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
  echo '' >>"$ZSHRC"
  add_line_if_missing 'export FZF_CTRL_R_OPTS="--style full"'
  add_line_if_missing 'export FZF_CTRL_T_OPTS="--style full --walker-skip .git,node_modules,target --preview '\''bat -n --color=always {}'\'' --bind '\''ctrl-/:change-preview-window(down|hidden|)'\''"'

  source "$ZSHRC"
else
  echo "Oh My Zsh already installed"
fi

# ===============================
#       ASDF Installation
# ===============================
if ! command -v asdf &>/dev/null; then

  echo "Installing asdf..."

  if [ ! -d "$ASDF_DIR" ]; then
    git clone https://aur.archlinux.org/asdf-vm.git "$ASDF_DIR"
    chown -R "$CURRENT_USER:$CURRENT_USER" "$ASDF_DIR"
  fi

  cd "$ASDF_DIR"
  sudo -u "$CURRENT_USER" bash -c "cd $ASDF_DIR && makepkg -si --noconfirm"

  add_line_if_missing 'export ASDF_DATA_DIR="$HOME/.asdf"'
  add_line_if_missing 'export PATH="$ASDF_DATA_DIR/shims:$PATH"'

else
  echo "asdf already installed"
fi

# Add Node.js e Python plugin to asdf
echo "Installing programming languages"

sudo -u "$CURRENT_USER" bash -c "
  if ! asdf plugin list | grep -q '^nodejs\$'; then
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs $NODE_VERSION
    asdf set -u nodejs $NODE_VERSION
  else 
    echo 'Node plugin already installed'
  fi
"

sudo -u "$CURRENT_USER" bash -c "
  if ! asdf plugin list | grep -q '^python\$'; then
    asdf plugin add python
    asdf install python $PYTHON_VERSION
    asdf set -u python $PYTHON_VERSION
  else 
    echo 'Python plugin already installed'
  fi
"

# ===============================
#       Vscode Installation
# ===============================
if ! pacman -Q visual-studio-code-bin &>/dev/null; then
  echo "Installing Visual Studio Code..."
  sudo -u "$CURRENT_USER" yay -S --noconfirm visual-studio-code-bin
else
  echo "Visual Studio Code is already installed."
fi

# ===============================
#   Google Chrome Installation
# ===============================
if ! pacman -Q google-chrome &>/dev/null; then
  echo "Installing Google Chrome..."
  sudo -u "$CURRENT_USER" yay -S --noconfirm google-chrome
else
  echo "Google Chrome is already installed."
fi

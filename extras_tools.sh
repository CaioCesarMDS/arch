#!/bin/bash

set -e

if [[ -z "$CURRENT_USER" || -z "$USER_HOME" ]]; then
  source ./global.env
fi

# ===============================
#       Environment Variables
# ===============================
ASDF_DIR="/opt/asdf"
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
if ! command -v asdf &>/dev/null; then
  echo "Installing flatpak"

  sudo pacman -S --noconfirm --needed flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # ===============================
  #       asdf Installation
  # ===============================
  echo "Installing asdf..."

  if [ ! -d "$ASDF_DIR" ]; then
    git clone https://aur.archlinux.org/asdf-vm.git "$ASDF_DIR"
    chown -R "$CURRENT_USER:$CURRENT_USER" "$ASDF_DIR"
  fi

  cd "$ASDF_DIR"
  sudo -u "$CURRENT_USER" bash -c "cd $ASDF_DIR && makepkg -si --noconfirm"

  if ! grep -qxF 'export ASDF_DATA_DIR="$HOME/.asdf"' "$ZSHRC"; then
    echo 'export ASDF_DATA_DIR="$HOME/.asdf"' >>"$ZSHRC"
  fi

  if ! grep -qxF 'export PATH="$ASDF_DATA_DIR/shims:$PATH"' "$ZSHRC"; then
    echo 'export PATH="$ASDF_DATA_DIR/shims:$PATH"' >>"$ZSHRC"
  fi
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

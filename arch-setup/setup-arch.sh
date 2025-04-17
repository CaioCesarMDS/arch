#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)"
  exit 1
fi

CURRENT_USER=$(logname)
USER_HOME=$(eval echo "~$CURRENT_USER")

# Update system
echo "Updating the system..."
pacman -Syu --noconfirm

# Install some packages
echo "Installing essential packages..."
pacman -S --noconfirm --needed \
  linux linux-firmware base base-devel \
  grub efibootmgr os-prober fuse3 intel-ucode \
  xdg-user-dirs pipewire pipewire-pulse networkmanager \
  nano git curl wget zsh fastfetch unzip zip p7zip \
  noto-fonts-emoji ttf-dejavu ttf-liberation \
  noto-fonts ttf-jetbrains-mono ttf-jetbrains-mono-nerd


# Install GRUB Bootloader
echo "Installing GRUB bootloader..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck

# Configure grub to find other OS's
echo "⚙️ Configuring GRUB to enable OS detection..."
GRUB_FILE="/etc/default/grub"
if grep -q "^#*GRUB_DISABLE_OS_PROBER=" "$GRUB_FILE"; then
  sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_FILE"
else
  echo "GRUB_DISABLE_OS_PROBER=false" >> "$GRUB_FILE"
fi

# Generate grub.cfg
echo "Generating grub.cfg..."
grub-mkconfig -o /boot/grub/grub.cfg

# Start services
echo "Enabling and starting services..."
systemctl enable NetworkManager
systemctl start NetworkManager

# Configure pacman to increase parallel package download
echo "Configuring pacman..."
PACMAN_FILE="/etc/pacman.conf"
sed -i '/^#\?ParallelDownloads\s*=.*/d' "$PACMAN_FILE"
echo "ParallelDownloads = 10" >> "$PACMAN_FILE"

# Configure sudoers for wheel group
echo "Configuring sudoers..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Create user directories
echo "Creating default user directories..."
sudo -u "$CURRENT_USER" xdg-user-dirs-update

# Set zsh as default shell
echo "Setting zsh as default shell for $CURRENT_USER..."
chsh -s "$(which zsh)" "$CURRENT_USER"

# Install yay
echo "Installing yay (AUR helper)..."
YAY_DIR="/opt/yay"
if [ ! -d "$YAY_DIR" ]; then
  git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
  chown -R "$CURRENT_USER:$CURRENT_USER" "$YAY_DIR"
fi

cd "$YAY_DIR"
sudo -u "$CURRENT_USER" bash -c "cd $YAY_DIR && makepkg -si --noconfirm"

# Install asdf
echo "Installing asdf..."
ASDF_DIR="/opt/asdf-vm"
if [ ! -d "$ASDF_DIR" ]; then
  git clone https://aur.archlinux.org/asdf-vm.git "$ASDF_DIR"
  chown -R "$CURRENT_USER:$CURRENT_USER" "$ASDF_DIR"
fi
cd "$ASDF_DIR"
sudo -u "$CURRENT_USER" bash -c "cd $ASDF_DIR && makepkg -si --noconfirm"

ZSHRC="$USER_HOME/.zshrc"
echo 'export PATH="$ASDF_DATA_DIR/shims:$PATH"' >> "$ZSHRC"
echo 'export ASDF_DATA_DIR="$HOME/.asdf"' >> "$ZSHRC"

echo "Asdf installed and configured in $CURRENT_USER's .zshrc"

echo "Installing programming languages"
## Add Node.js plugin to asdf and install
sudo -u "$CURRENT_USER" bash -c '
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs 22.14.0
  asdf set -u nodejs 22.14.0
'

## Add Python plugin to asdf and install
sudo -u "$CURRENT_USER" bash -c '
  asdf plugin add python
  asdf install python 3.12.10
  asdf set -u python 3.12.10
'

# Install vscode
echo "💻 Installing Visual Studio Code..."
sudo -u "$CURRENT_USER" yay -S --noconfirm visual-studio-code-bin

# Instal chrome
echo "💻 Installing Google Chrome..."
sudo -u "$CURRENT_USER" yay -S --noconfirm google-chrome

# End
echo -e "\n✅ Initial Arch setup is complete! Please reboot your PC."

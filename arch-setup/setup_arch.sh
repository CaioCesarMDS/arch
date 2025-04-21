#!/bin/bash

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)"
  exit 1
fi

CURRENT_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$CURRENT_USER")

export CURRENT_USER
export USER_HOME

# Update system
echo "Updating the system..."

pacman -Syu --noconfirm

# Install some packages
echo "Installing essential packages..."

pacman -S --noconfirm --needed \
  linux linux-firmware base base-devel \
  grub efibootmgr os-prober fuse3 intel-ucode \
  xdg-user-dirs pipewire pipewire-pulse networkmanager \
  nano git sassc curl wget zsh ufw fastfetch unzip zip p7zip \
  gst-plugins-ugly gst-plugins-good gst-plugins-base languagetool \
  gst-plugins-bad gst-libav gstreamer ffmpeg pacman-contrib vlc \
  noto-fonts-emoji noto-fonts-cjk noto-fonts ttf-dejavu ttf-liberation \
  ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-bitstream-vera \


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
systemctl enable paccache.timer
ufw enable

# Configure pacman to increase parallel package download
echo "Configuring pacman..."

PACMAN_FILE="/etc/pacman.conf"

if grep -q "^[#]*ParallelDownloads" "$PACMAN_FILE"; then
  sed -i 's/^[#]*ParallelDownloads.*/ParallelDownloads = 10/' "$PACMAN_FILE"
else
  sed -i '/^\[options\]/a ParallelDownloads = 10' "$PACMAN_FILE"
fi

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

#Install Flatpak 
echo "Installing flatpak"

sudo pacman -S --noconfirm --needed flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install asdf
echo "Installing asdf..."

ASDF_DIR="/opt/asdf-vm"
ZSHRC="$USER_HOME/.zshrc"
NODE_VERSION="22.14.0"
PYTHON_VERSION="3.12.10"

if [ ! -d "$ASDF_DIR" ]; then
  git clone https://aur.archlinux.org/asdf-vm.git "$ASDF_DIR"
  chown -R "$CURRENT_USER:$CURRENT_USER" "$ASDF_DIR"
fi

cd "$ASDF_DIR"
sudo -u "$CURRENT_USER" bash -c "cd $ASDF_DIR && makepkg -si --noconfirm"

echo 'export ASDF_DATA_DIR="$HOME/.asdf"' >> "$ZSHRC"
echo 'export PATH="$ASDF_DATA_DIR/shims:$PATH"' >> "$ZSHRC"

## Add Node.js plugin to asdf and install
echo "Installing programming languages"

sudo -u "$CURRENT_USER" bash -c "
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs $NODE_VERSION
  asdf set -u nodejs $NODE_VERSION
"

## Add Python plugin to asdf and install
sudo -u "$CURRENT_USER" bash -c " 
  asdf plugin add python
  asdf install python $PYTHON_VERSION
  asdf set -u python $PYTHON_VERSION
"

# Install vscode
echo "💻 Installing Visual Studio Code..."
sudo -u "$CURRENT_USER" yay -S --noconfirm visual-studio-code-bin

# Instal chrome
echo "💻 Installing Google Chrome..."
sudo -u "$CURRENT_USER" yay -S --noconfirm google-chrome

# End
echo -e "\n✅ Initial Arch setup is complete! Please reboot your PC."

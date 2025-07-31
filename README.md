# ⚡ Arch + Hyprland Setup Script

## 📌 About the Project

Automated Arch Linux post-install script focused on setting up a Wayland desktop using Hyprland, with sane defaults, essential tools, and visual polish.


<br>

## 📎 Prerequisites and Guidelines

- Arch Linux must be already installed
- Internet connection
- `git` installed

<br>

## 📁 Project Structure

```txt
.
├── assets/                                # Project assets
│   └── wallpapers/
│       └── clouds.png
├── .config/                               # Dotfiles and configs
├── core/                                  # Core system setup scripts
│   ├── configure_system.sh
│   ├── env.sh
│   ├── extras_tools.sh
│   └── install_packages.sh
├── hyprland/                              # Hyprland-specific setup
│   ├── configure_system.sh
│   └── install_packages.sh
├── README.md
├── setup.sh                               # Main installer script
└── utils.sh                               # Utility functions

```

<br>

## ✨ Main Features

- Window manager: **Hyprland** with portal and utilities  
- Notifications: **SwayNC**  
- Launcher: **Wofi**  
- Terminal: **Kitty**  
- Clipboard manager: **Cliphist**  
- Shell: **zsh** + **oh-my-zsh** + **Starship**  
- Login manager: **SDDM**  
- AUR helper: **yay**  
- Custom Waybar, wallpapers, fonts
- Essential utilities: **btop**, **curl**, **git**, **imagemagick**, **neovim**, etc.

<br>

## 🛠️ Installation

> [!IMPORTANT]
>
> This script is designed for UEFI systems only.
>

> [!WARNING]
>
> Make sure to backup your data before proceeding.
>

> [!CAUTION]
>
> This script is <em>experimental</em> and intended for newly installed systems only. Use at your own risk.
>

```bash
git clone https://github.com/CaioCesarMDS/arch.git --depth 1 --branch main
cd arch
chmod +x setup.sh
sudo ./setup.sh
```

<br>

## 📦 Full List of Installed Packages

<br/>

### 🔧 Core System Packages

```
base base-devel efibootmgr grub fuse3 intel-ucode linux linux-firmware

linux-headers networkmanager pipewire pipewire-pulse os-prober

xdg-user-dirs wireplumber
```

### 🧰 Utilities and CLI Tools

```
blueman bluez bluez-utils btop curl fastfetch git imagemagick

inetutils jq languagetool man-db man-pages nano openssh openssl p7zip

pacman-contrib procps-ng sassc tcl tk tree ufw unzip usbutils

neovim xz wget zip zlib zsh
```

### 🎞️ Multimedia Support

```
ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base

gst-plugins-bad gst-libav gstreamer mpv
```

### 🖋 Fonts

```
noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

ttf-bitstream-vera ttf-dejavu ttf-firacode-nerd ttf-font-awesome

ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-liberation

ttf-meslo-nerd ttf-nerd-fonts-symbols
```

### 🎨 Desktop & Hyprland Environment

```
hyprland hypridle hyprlock hyprpolkitagent kitty

qt5-wayland qt6-wayland sddm swww xdg-desktop-portal-hyprland

xdg-desktop-portal-gtk
```

### 🧩 System Utilities

```
cliphist dolphin swaync waybar wofi wl-clipboard

pavucontrol pamixer
```

### 🧰 KDE Extras

```
ark dolphin-plugins ffmpegthumbs gvfs kde-cli-tools

kio-admin qt5-imageformats qt5-quickcontrols qt5-quickcontrols2

qt5-graphicaleffects
```

<br>

## 🧠 Credits

<p>Inspired by various dotfiles and scripts from the Arch Linux community.</p>

<p>Mainly by the following projects:</p>

<ul>
    <li><a href="https://github.com/HyDE-Project/HyDE">HyDE</a></li>
    <li><a href="https://github.com/elifouts/Dotfiles">Dotfiles</a></li>
</ul>

<br>

## 📜 License

This project is licensed under the **GNU General Public License v3.0**.  
See the [LICENSE](./LICENSE) file for more details.


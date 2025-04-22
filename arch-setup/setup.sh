#!/bin/bash

set -e

if [ -f ./global.env ]; then
  source ./global.env
else
  echo "global.env not found!"; 
  exit 1;
fi

# ===============================
#   Check if running as root
# ===============================
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root (use sudo)"
  exit 1
fi

echo -e "\n==============================="
echo "  Starting Arch Linux Setup"
echo -e "===============================\n"

# ===============================
#         Update system
# ===============================
echo "Updating the system..."
pacman -Syu --noconfirm

# ===============================
#   Install essential packages
# ===============================
if [ -f ./install_pkg.sh ]; then
  source ./install_pkg.sh
else
  echo "install_pkg.sh not found!"; 
  exit 1;
fi

# ===============================
#   Configure GRUB, pacman, ...
# ===============================
if [ -f ./configure_system.sh ]; then
  source ./configure_system.sh
else
  echo "configure_system.sh not found!";
  exit 1;
fi

# ======================================
# Install additional software and tools
# ======================================
if [ -f ./extras_tools.sh ]; then
  source ./extras_tools.sh
else
  echo "extras_tools.sh not found!";
  exit 1;
fi

# ===============================
#           End
# ===============================
read -rp "Reboot now? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  reboot
else
  echo "You can reboot manually when you're ready."
fi

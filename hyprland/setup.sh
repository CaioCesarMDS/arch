#!/bin/bash

set -e

echo -e "\n==============================="
echo "  Starting Hyprland Setup"
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
#   Configure system
# ===============================
if [ -f ./configure_system.sh ]; then
  source ./configure_system.sh
else
  echo "configure_system.sh not found!";
  exit 1;
fi

# ===============================
#             End
# ===============================
echo "Installation is complete!"
#!/bin/bash

set -e

# ===============================
#   Enabling SDDM Service
# ===============================
echo "Enabling SDDM..."
sudo systemctl enable sddm.service --now


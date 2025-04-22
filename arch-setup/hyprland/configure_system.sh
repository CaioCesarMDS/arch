#!/bin/bash

set -e

echo "Enabling SDDM..."
sudo systemctl enable sddm.service --now
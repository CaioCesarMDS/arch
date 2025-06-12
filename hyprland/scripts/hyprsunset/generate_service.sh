#!/bin/bash

set -e

SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/hyprsunset.service"

mkdir -p "$SERVICE_DIR"

cat >"$SERVICE_FILE" <<EOF
[Unit]
Description=Run hyprsunset

[Service]
Type=oneshot
Environment=DISPLAY=:1
Environment=XDG_RUNTIME_DIR=/run/user/%U
ExecStart=/bin/bash $HOME/.config/scripts/hyprsunset/hyprsunset_autostart.sh
RemainAfterExit=true

[Install]
WantedBy=default.target
EOF

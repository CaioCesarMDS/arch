#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/hyprsunset"

MANUAL_MODE_FILE="$CONFIG_DIR/hyprsunset_manual"

if [ -e "$MANUAL_MODE_FILE" ]; then
    echo true
else
    echo false
fi
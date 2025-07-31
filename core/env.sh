#!/usr/bin/env bash

set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$THIS_DIR/../utils.sh"

export CURRENT_USER=${SUDO_USER:-$USER}
export USER_HOME=$(eval echo "~$CURRENT_USER")

if [[ -z "$CURRENT_USER" || -z "$USER_HOME" ]]; then
    log_error "CURRENT_USER or USER_HOME is not set correctly."
    exit 1
fi

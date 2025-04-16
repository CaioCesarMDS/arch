#!/bin/bash

if ! command -v asdf &> /dev/null; then
  echo "❌ asdf is not available in the PATH. Have you rebooted or relogged?"
  exit 1
fi

CURRENT_USER=$(logname)

# Add Node.js plugin to asdf and install
sudo -u "$CURRENT_USER" bash -c '
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs 22.14.0
  asdf set -u nodejs 22.14.0
'

# Add Python plugin to asdf and install
sudo -u "$CURRENT_USER" bash -c '
  asdf plugin add python
  asdf install python 3.12.10
  asdf set -u python 3.12.10
'





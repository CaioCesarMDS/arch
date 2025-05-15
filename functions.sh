#!/usr/bin/bash

if [[ -z "$CURRENT_USER" || -z "$USER_HOME" ]]; then
  source ./global.env
fi

ZSHRC="$USER_HOME/.zshrc"

add_line_if_missing() {
  local line="$1"

  if ! grep -qxF "$line" "$ZSHRC"; then
    echo "$line" >> "$ZSHRC"
  fi
}

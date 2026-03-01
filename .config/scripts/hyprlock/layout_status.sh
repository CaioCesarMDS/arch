#!/usr/bin/env bash

output=""

check_layout() {
  local layout="$(cat /etc/vconsole.conf | grep XKBLAYOUT | awk -F'=' '{print toupper($2)}')"
  if [[ -n "$layout" ]]; then
    output+="$layout "
  else
    output+="󰌐"
  fi
}

check_layout
echo "$output"

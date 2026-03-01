#!/usr/bin/env sh

LOCKFILE="/tmp/hyprsunset_toggle.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 1

desired_temp=4800

if [[ "$1" != "--toggle" ]]; then
  if pgrep -x hyprsunset >/dev/null; then
    echo "󰤄"
  else
    echo ""
  fi
  flock -u 200
  exit 0
fi

if pgrep -x hyprsunset >/dev/null; then
  pkill hyprsunset
else
  hyprsunset -t "$desired_temp" &
fi

pkill -RTMIN+1 waybar

flock -u 200
exit 0

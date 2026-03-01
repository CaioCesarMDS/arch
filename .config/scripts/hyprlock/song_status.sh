#!/usr/bin/env bash

output=""
MAX_LENGTH=40

check_song() {
  local players player_name player_status icon title artist info len

  players=$(playerctl -l 2>/dev/null)

  for player_name in $players; do
    player_status=$(playerctl -p "$player_name" status 2>/dev/null)

    if [[ "$player_status" != "Playing" ]]; then
      continue
    fi

    case "$player_name" in
    spotify) icon="󰓇" ;;
    firefox) icon="󰈹" ;;
    mpd) icon="󰎆" ;;
    chromium) icon="󰊯" ;;
    *) icon="" ;;
    esac

    title=$(playerctl -p "$player_name" metadata title 2>/dev/null)
    artist=$(playerctl -p "$player_name" metadata artist 2>/dev/null)

    info="$title  $icon  $artist"
    len=${#info}
    if ((len > MAX_LENGTH)); then
      info="${info:0:MAX_LENGTH-3}…"
    fi

    output+="$info "
    break
  done
}

check_song
echo "$output"

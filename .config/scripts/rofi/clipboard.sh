#!/usr/bin/env bash
set -euo pipefail

pkill -u "$USER" -x rofi 2>/dev/null || true

readonly FAVORITES_FILE="$HOME/.cache/clipboard/clipboard_favorites"
readonly CLIPBOARD_THEME_FILE="$HOME/.config/rofi/clipboard.rasi"

DEL_MODE=false

run_rofi() {
  rofi -dmenu -theme "$CLIPBOARD_THEME_FILE"
}

process_selections() {
  if $DEL_MODE; then
    while IFS= read -r line; do
      [ -n "$line" ] && cliphist delete <<<"$line"
    done
  else
    while IFS= read -r line; do
      [ -n "$line" ] && echo -e "$line\t" | cliphist decode
    done | wl-copy
  fi
}

show_history() {
  mapfile -t items < <(cliphist list | sed '/^\s*$/d')
  [ ${#items[@]} -eq 0 ] && return

  local list=()
  for i in "${!items[@]}"; do
    list+=("$((i + 1)). ${items[i]}")
  done

  selection=$(printf '%s\n' "${list[@]}" | run_rofi) || return

  while IFS= read -r sel; do
    idx=$(awk -F'.' '{print $1}' <<<"$sel")
    if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le ${#items[@]} ]; then
      echo "${items[$((idx - 1))]}"
    fi
  done <<<"$selection" | process_selections
}

delete_items() {
  DEL_MODE=true
  show_history
}

clear_history() {
  cliphist wipe
}

fav_decode_array() {
  local -n _out=$1
  _out=()
  local line
  while IFS= read -r line; do
    _out+=("$(printf '%s' "$line" | base64 --decode | tr '\n' ' ')")
  done <"$FAVORITES_FILE"
}

pick_from_list() {
  local list=("$@")
  printf '%s\n' "${list[@]}" | run_rofi
}

add_to_favorites() {
  mkdir -p "$(dirname "$FAVORITES_FILE")"

  mapfile -t items < <(cliphist list | sed '/^\s*$/d')
  [ ${#items[@]} -eq 0 ] && {
    notify-send "Clipboard" "No items to favorite."
    return
  }

  selection=$(pick_from_list "${items[@]}") || return

  id=$(cut -f1 <<<"$selection")

  decoded=$(printf '%s\t' "$id" | cliphist decode) || {
    notify-send "Clipboard" "Failed to decode cliphist id: $id"
    return
  }

  if [ -z "$decoded" ]; then
    notify-send "Clipboard" "Decoded content empty for id: $id"
    return
  fi

  encoded=$(printf "%s" "$decoded" | base64 -w0)
  if ! grep -Fxq "$encoded" "$FAVORITES_FILE" 2>/dev/null; then
    printf '%s\n' "$encoded" >>"$FAVORITES_FILE"
    notify-send "Clipboard" "Added to favorites"
  else
    notify-send "Clipboard" "Already a favorite"
  fi
}

view_favorites() {
  [ -s "$FAVORITES_FILE" ] || {
    notify-send "Clipboard" "No favorites."
    return
  }

  mapfile -t favs <"$FAVORITES_FILE"
  fav_decode_array decoded

  local list=()
  for i in "${!decoded[@]}"; do
    list+=("$((i + 1)). ${decoded[i]}")
  done

  selection=$(printf '%s\n' "${list[@]}" | run_rofi) || return

  idx=$(awk -F'.' '{print $1}' <<<"$selection")

  if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le ${#favs[@]} ]; then
    echo "${favs[$((idx - 1))]}" | base64 --decode | wl-copy
    notify-send "Clipboard" "#$idx copied to clipboard"
  else
    notify-send "Clipboard" "Invalid selection"
  fi
}

delete_from_favorites() {
  [ -s "$FAVORITES_FILE" ] || {
    notify-send "Clipboard" "No favorites."
    return
  }

  mapfile -t favs <"$FAVORITES_FILE"
  fav_decode_array decoded

  local list=()
  for i in "${!decoded[@]}"; do
    list+=("$((i + 1)). ${decoded[i]}")
  done

  selection=$(printf '%s\n' "${list[@]}" | run_rofi) || return
  idx=$(awk -F'.' '{print $1}' <<<"$selection")

  if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le ${#favs[@]} ]; then
    sed -i "${idx}d" "$FAVORITES_FILE"
    notify-send "Clipboard" "Removed #$idx from favorites"
  else
    notify-send "Clipboard" "Invalid selection"
  fi
}

clear_favorites() {
  : >"$FAVORITES_FILE"
}

manage_favorites() {
  local manage
  manage=$(printf '%s\n' "Add" "Delete" "Clear" | run_rofi) || return
  case "$manage" in
  Add) add_to_favorites ;;
  Delete) delete_from_favorites ;;
  Clear) clear_favorites ;;
  esac
}

main() {
  local action="${1:-}"
  [ -z "$action" ] && action=$(printf '%s\n' "History" "Delete" "View Favorites" "Manage Favorites" "Clear History" | run_rofi)

  case "$action" in
  -c | --copy | "History") show_history ;;
  "Delete") delete_items ;;
  -f | --favorites | "View Favorites") view_favorites ;;
  "Manage Favorites") manage_favorites ;;
  -w | --wipe | "Clear History") clear_history ;;
  -h | --help | *) echo "Usage: $0 [ --copy | --favorites | --wipe | --help ]" ;;
  esac
}

main "$@"

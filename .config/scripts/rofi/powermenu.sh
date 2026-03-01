#!/usr/bin/env bash
set -euo pipefail

pkill -u "$USER" -x rofi 2>/dev/null || true

readonly ROFI_DIR="$HOME/.config/rofi"
readonly POWERMENU_THEME_FILE="$ROFI_DIR/powermenu.rasi"
readonly CONFIRM_THEME_FILE="$ROFI_DIR/confirm.rasi"

get_system_info() {
  LAST_LOGIN="$(last -n1 "$USER" |
    grep -E 'still logged in|logged in' |
    head -n1 |
    tr -s ' ' |
    awk '{print $4" "$5" "$6}')"
  UPTIME="$(uptime -p | sed 's/^up //')"
  HOSTNAME="$(hostname)"
}

set_icons() {
  declare -gA ACTIONS=(
    [""]="SHUTDOWN"
    [""]="REBOOT"
    ["󰍃"]="LOGOUT"
    ["󰌾"]="LOCK"
    ["󰏤"]="SUSPEND"
    ["󰤄"]="HIBERNATE"
  )
  ORDERED_ICONS=("" "" "󰍃" "󰌾" "󰏤" "󰤄")
  ICON_YES=''
  ICON_NO='󰅙'
}

confirm_action() {
  printf "%s\n%s\n" "$ICON_YES" "$ICON_NO" |
    rofi -dmenu -p "Confirmation" \
      -mesg "Are you sure?" \
      -theme "$CONFIRM_THEME_FILE"
}

show_menu() {
  local menu_items
  menu_items="$(printf "%s\n" "${ORDERED_ICONS[@]}")"
  rofi -dmenu -p " $USER@$HOSTNAME" \
    -mesg " Last Login: $LAST_LOGIN |  Uptime: $UPTIME" \
    -theme "$POWERMENU_THEME_FILE" <<<"$menu_items"
}

execute_action() {
  local selected_icon="$1"
  local action="${ACTIONS[$selected_icon]:-}"

  [[ -z "$action" ]] && exit 1

  if [[ "$action" != "LOCK" ]]; then
    local confirmed
    confirmed="$(confirm_action)"
    [[ "${confirmed// /}" != "${ICON_YES// /}" ]] && return
  fi

  case "$action" in
  SHUTDOWN) systemctl poweroff ;;
  REBOOT) systemctl reboot ;;
  LOGOUT) hyprctl dispatch exit 0 ;;
  LOCK) hyprlock ;;
  SUSPEND) systemctl suspend ;;
  HIBERNATE) systemctl hibernate ;;
  esac
}

main() {
  get_system_info
  set_icons

  local selected_icon
  selected_icon="$(show_menu)"
  [[ -n "$selected_icon" ]] && execute_action "$selected_icon"
}

main "$@"

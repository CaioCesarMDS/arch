#!/usr/bin/env sh

check() {
  command -v "$1" >/dev/null
}

loc="$HOME/.cache/colorpicker"
mkdir -p "$loc"
touch "$loc/colors"

limit=10

if [[ $# -eq 1 && $1 == "-l" ]]; then
  cat "$loc/colors"
  exit 0
fi

if [[ $# -eq 1 && $1 == "-j" ]]; then
  text="$(head -n 1 "$loc/colors")"

  if ! [[ "$text" =~ ^#[0-9a-fA-F]{6}$ ]]; then
    text="#ffffff"
  fi

  mapfile -t allcolors < <(tail -n +2 "$loc/colors")

  tooltip="<b>   COLORS</b>\n\n"
  tooltip+="-> <b>$text</b>  <span color='$text'></span>  \n"
  for i in "${allcolors[@]}"; do
    if [[ "$i" =~ ^#[0-9a-fA-F]{6}$ ]]; then
      tooltip+="   <b>$i</b>  <span color='$i'></span>  \n"
    fi
  done

  tooltip="${tooltip//$'\n'/\\n}"

  cat <<EOF
{ "text":"<span color='$text'></span>", "tooltip":"$tooltip"}
EOF
  exit 0
fi

if ! check hyprpicker; then
  notify-send "Color Picker" "Hyprpicker is not installed"
  exit 1
fi

pkill -x hyprpicker 2>/dev/null || true

color=$(hyprpicker | tr -d '\n')

if [[ -z "$color" ]]; then
  notify-send "Color Picker" "No color selected"
  exit 1
fi

if ! [[ "$color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
  notify-send "Color Picker" "Invalid color format: $color"
  exit 1
fi

if check wl-copy; then
  echo "$color" | wl-copy
fi

prevColors=$(grep -vFx "$color" "$loc/colors" 2>/dev/null | head -n $((limit - 1)))

{
  echo "$color"
  echo "$prevColors"
} | sed '/^$/d' >"$loc/colors"

if [[ -f ~/.cache/wal/colors.sh ]]; then
  source ~/.cache/wal/colors.sh
fi

if [[ -n "$wallpaper" ]]; then
  notify-send "Color Picker" "Selected: $color" -i "$wallpaper"
else
  notify-send "Color Picker" "Selected: $color"
fi

pkill -RTMIN+1 waybar

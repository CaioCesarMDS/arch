#!/usr/bin/env bash
set -euo pipefail

pkill -u "$USER" -x rofi 2>/dev/null || true

set_once() {
  local name="$1" value="$2"
  if ! declare -p "$name" >/dev/null 2>&1; then
    readonly "$name"="$value"
  fi
}

ensure_symlink() {
  local target="$1"
  local link="$2"

  mkdir -p "$(dirname "$link")"

  if [ ! -L "$link" ] || [ "$(readlink "$link")" != "$target" ]; then
    ln -sf "$target" "$link"
  fi
}

readonly WALLPAPERS_DIR="${WALLPAPERS_DIR:-$HOME/Wallpapers}"
set_once CACHE_DIR "$HOME/.cache"

readonly WALLPAPERS_CACHE_DIR="$CACHE_DIR/wallpaper"
mkdir -p "$WALLPAPERS_CACHE_DIR"

readonly THUMB_DIR="$WALLPAPERS_CACHE_DIR/thumbs"
mkdir -p "$THUMB_DIR"

readonly CURRENT_WALLPAPER="$WALLPAPERS_CACHE_DIR/current"
readonly WALLPAPER_THEME_FILE="$HOME/.config/rofi/wallpaper.rasi"

mapfile -t WALL_LIST < <(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort)
[ ${#WALL_LIST[@]} -eq 0 ] && {
  echo "No wallpapers found in directory: $WALLPAPERS_DIR"
  exit 1
}

thumb_for() {
    local file="$1" h
    if command -v sha256sum >/dev/null 2>&1; then
        h=$(sha256sum -- "$file" | awk '{print $1}')
    else
        h=$(md5sum -- "$file" | awk '{print $1}')
    fi
    printf "%s/%s.png" "$THUMB_DIR" "$h"
}

generate_thumb() {
    local src="$1" dst="$2"
    [ -f "$dst" ] && [ -s "$dst" ] && return 0

    local -r px="512x512"
    local -r quality=85

    if command -v magick >/dev/null 2>&1; then
        magick "$src" -auto-orient -thumbnail "$px^" -gravity center -extent "$px" -strip -quality "$quality" "$dst" 2>/dev/null || {
            rm -f "$dst"
            return 1
        }
        return 0
    fi
    return 1
}

set_wall() {
    local wall="$1"
    [ ! -f "$wall" ] && {
        echo "File not found: $wall"
        return 1
    }

    local current
    current=$(readlink -f "$CURRENT_WALLPAPER" 2>/dev/null || true)

    if [[ "$current" != "$wall" ]]; then
        echo "Setting wallpaper: $wall"
        ensure_symlink "$wall" "$CURRENT_WALLPAPER"
    fi
    swww img "$wall" --transition-type any --transition-fps 60 --transition-duration .5

    notify-send -a "rofi" -i "$wall" -u low "Wallpaper changed" "Wallpaper set to: $(basename "$wall")"
}

get_current_index() {
    local cur
    cur=$(basename "$(readlink -f "$CURRENT_WALLPAPER" 2>/dev/null || echo "")")
    for i in "${!WALL_LIST[@]}"; do
        [[ "$(basename "${WALL_LIST[$i]}")" == "$cur" ]] && {
            echo "$i"
            return 0
        }
    done
    echo 0
}

next_wall() {
    local idx
    idx=$(get_current_index)
    set_wall "${WALL_LIST[$(((idx + 1) % ${#WALL_LIST[@]}))]}"
}

prev_wall() {
    local idx
    idx=$(get_current_index)
    set_wall "${WALL_LIST[$(((idx - 1 + ${#WALL_LIST[@]}) % ${#WALL_LIST[@]}))]}"
}

random_wall() {
    local current next idx
    current=$(readlink -f "$CURRENT_WALLPAPER" 2>/dev/null || true)

    [ "${#WALL_LIST[@]}" -le 1 ] && {
        set_wall "${WALL_LIST[0]}"
        return 0
    }

  while :; do
    idx=$((RANDOM % ${#WALL_LIST[@]}))
    next="${WALL_LIST[$idx]}"
    [[ "$next" != "$current" ]] && break
  done

  set_wall "$next"
}

wallpaper_to_rofi_line() {
    local f="$1"
    local name=$(basename "$f")
    local thumb=$(thumb_for "$f")

    if generate_thumb "$f" "$thumb"; then
        printf '%s:::%s:::%s\0icon\x1f%s\n' "$name" "$f" "$thumb" "$thumb"
    else
        printf '%s:::%s:::%s\0icon\x1fthumbnail://%s\n' "$name" "$f" "$f" "$f"
    fi
}

generate_rofi_lines() {
    local lines_file=$(mktemp)

    for f in "${WALL_LIST[@]}"; do
        wallpaper_to_rofi_line "$f" >>"$lines_file"
    done

    echo "$lines_file"
}

get_rofi_style() {
    local columns=4
    local thumb_px=512

    cat <<EOF
        listview{columns:${columns}; spacing:5em;}
        element{orientation:vertical; border-radius:20px;}
        element-icon{size:26em;border-radius:0px;}
        element-text{padding:1em;}
EOF
}

select_wall() {
    [ ${#WALL_LIST[@]} -eq 0 ] && exit 1

    local lines_file
    lines_file=$(generate_rofi_lines)

    cleanup_lines_file() {
        [[ -n "${lines_file:-}" && -f "$lines_file" ]] && rm -f "$lines_file"
    }
    trap cleanup_lines_file RETURN

    local rofi_style
    rofi_style=$(get_rofi_style)

    local choice
    choice=$(rofi -dmenu -show-icons \
        -display-column-separator ":::" -display-columns 1 \
        -theme-str "$rofi_style" \
        -theme "$WALLPAPER_THEME_FILE" <"$lines_file")

    [ -z "$choice" ] && return 1

    local selected_path=$(awk -F ':::' '{print $2}' <<<"$choice")
    [ -n "$selected_path" ] && [ -f "$selected_path" ] && set_wall "$selected_path" && return 0

    echo "Selected file does not exist: $selected_path" >&2
    exit 1
}

main() {
  case "${1-}" in
  -n | --next) next_wall ;;
  -p | --prev) prev_wall ;;
  -r | --random) random_wall ;;
  -s | --set) set_wall "${2:?Error: Please provide a wallpaper file path}" ;;
  -S | --select) select_wall ;;
  -c | --current) readlink -f "$CURRENT_WALLPAPER" ;;
  -h | --help | *) echo "Uso: $0 [ --next | --prev | --random | --set <wallpaper> | --select | --current ]" ;;
  esac
}

main "$@"

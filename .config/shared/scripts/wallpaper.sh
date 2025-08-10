#!/usr/bin/env sh

WALLPAPER_DIR="$HOME/Wallpapers/"

menu() {
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
}

main() {
    mkdir -p "$WALLPAPER_DIR/active_wallpaper"

    choice=$(menu | wofi -c ~/.config/wofi/wallpaper/config -s ~/.config/wofi/wallpaper/style.css --show dmenu --prompt "Select Wallpaper:" -n)

    selected_wallpaper=$(echo "$choice" | sed 's/^img://')

    if [ -z "$selected_wallpaper" ]; then
        exit 1
    fi

    swww img "$selected_wallpaper" --transition-type any --transition-fps 60 --transition-duration .5
    wal -i "$selected_wallpaper"
    swaync-client --reload-css
    pywalfox update
    # color1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    # color2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    # cava_config="$HOME/.config/cava/config"
    # sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" $cava_config
    # sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" $cava_config
    # pkill -USR2 cava 2>/dev/null
    ext="${selected_wallpaper##*.}"
    source ~/.cache/wal/colors.sh && cp "$selected_wallpaper" "$HOME/Wallpapers/active_wallpaper/active.$ext"
}
main

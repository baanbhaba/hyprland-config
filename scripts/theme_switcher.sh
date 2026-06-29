#!/bin/bash

# -----------------------------------------------------
# THEME SWITCHER - Hyprland
# Switch between Charcoal, Jaipur, and Color Block themes
# -----------------------------------------------------

THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/.theme_current"

get_current_theme() {
    if [ -f "$CURRENT_THEME_FILE" ]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "charcoal"
    fi
}

set_theme() {
    local theme=$1
    echo "$theme" > "$CURRENT_THEME_FILE"
    
    # Hyprland
    ln -sf "$THEMES_DIR/$theme/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
    
    # Hyprlock
    ln -sf "$THEMES_DIR/$theme/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
    
    # Kitty
    sed -i "s|^include .*|include ~/.config/kitty/themes/$theme.conf|" "$HOME/.config/kitty/kitty.conf"
    
    # Waybar
    ln -sf "$HOME/.config/waybar/themes/$theme/config" "$HOME/.config/waybar/config"
    ln -sf "$HOME/.config/waybar/themes/$theme/style.css" "$HOME/.config/waybar/style.css"
    
    # Mako
    ln -sf "$HOME/.config/mako/themes/$theme" "$HOME/.config/mako/config"
    
    # Btop - use theme name, not path
    sed -i "s|color_theme = .*|color_theme = \"$theme\"|" "$HOME/.config/btop/btop.conf"
    
    reload_all
    # Restart btop
    pkill btop 2>/dev/null || true
}

reload_all() {
    # Restart btop
    pkill btop 2>/dev/null || true
    hyprctl reload
    killall waybar 2>/dev/null
    waybar &
    makoctl reload 2>/dev/null || (killall mako 2>/dev/null && mako &)
    pkill -SIGUSR1 kitty 2>/dev/null
    ~/.config/hypr/scripts/wallpaper.sh
    notify-send "Theme Switcher" "Switched to $(get_current_theme | tr '[:lower:]' '[:upper:]') theme" -i color-select
}

show_menu() {
    local current=$(get_current_theme)
    local options="Charcoal\nJaipur\nColorBlock"
    
    local rofi_theme="$HOME/.config/rofi/themes/${current}.rasi"
    if [ ! -f "$rofi_theme" ]; then
        rofi_theme="$HOME/.config/rofi/themes/charcoal.rasi"
    fi
    
    local chosen=$(echo -e "$options" | rofi -dmenu -i -p "Select Theme" -theme "$rofi_theme")
    
    case "$chosen" in
        "Charcoal") set_theme "charcoal" ;;
        "Jaipur") set_theme "jaipur" ;;
        "ColorBlock") set_theme "colorblock" ;;
        *) exit 0 ;;
    esac
}

if [ "$1" = "--set" ] && [ -n "$2" ]; then
    if [ -d "$THEMES_DIR/$2" ]; then
        set_theme "$2"
    else
        echo "Theme '$2' not found"
        exit 1
    fi
else
    show_menu
fi

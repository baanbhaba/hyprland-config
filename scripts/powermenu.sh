#!/bin/bash

lock="󰌾  Lock"
shutdown="  Shutdown"
reboot="󰜉  Reboot"
logout="󰈆  Logout"
options="$shutdown\n$reboot\n$logout\n$lock"

# Use the current theme's Rofi
THEME=$(cat ~/.config/hypr/.theme_current 2>/dev/null || echo "charcoal")
rofi_theme="$HOME/.config/rofi/themes/${THEME}.rasi"
if [ ! -f "$rofi_theme" ]; then
    rofi_theme="$HOME/.config/rofi/themes/charcoal.rasi"
fi

chosen="$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme "$rofi_theme")"

case "$chosen" in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $logout)
        hyprctl dispatch exit
        ;;
    $lock)
        hyprlock
        ;;
esac

#!/bin/bash

# -----------------------------------------------------
# WALLPAPER SWITCHER - Cycle through wallpapers
# -----------------------------------------------------

THEME=$(cat ~/.config/hypr/.theme_current)
WALLPAPER_DIR="$HOME/.config/hypr/themes/$THEME/wallpapers"
INDEX_FILE="/tmp/current_wallpaper_index"

# Kill existing swaybg
killall swaybg 2>/dev/null

# Check if directory exists and has images
if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    # Get all images in the directory
    mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \))
    
    if [ ${#WALLPAPERS[@]} -gt 0 ]; then
        # Read current index or set to 0
        if [ -f "$INDEX_FILE" ]; then
            CURRENT_INDEX=$(cat "$INDEX_FILE")
            NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
        else
            NEXT_INDEX=0
        fi
        
        # Set wallpaper
        WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"
        swaybg -i "$WALLPAPER" -m fill &
        
        # Save next index for next time
        echo "$NEXT_INDEX" > "$INDEX_FILE"
        
        # Send notification
        notify-send "Wallpaper" "Changed to: $(basename "$WALLPAPER")"
    fi
fi

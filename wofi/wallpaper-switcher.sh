#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="/tmp/wallpaper-switcher-thumbs"
STYLE="$HOME/.config/wofi/wallpaper-switcher.css"
TRANSITIONS=("simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "any" "outer" "random")

# Generate thumbnails so wofi renders large previews
mkdir -p "$THUMB_DIR"
entries=""
while IFS= read -r file; do
    name=$(basename "$file")
    thumb="$THUMB_DIR/$name"
    # Only regenerate if source is newer than thumbnail
    if [[ ! -f "$thumb" || "$file" -nt "$thumb" ]]; then
        magick "$file" -resize 256x144^ -gravity center -extent 256x144 "$thumb" 2>/dev/null
    fi
    entries+="img:${thumb}:text:${name}"$'\n'
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) | sort)

# Pick a wallpaper
selection=$(printf '%s' "$entries" | wofi --dmenu --prompt " Wallpaper" \
    --style "$STYLE" \
    --allow-images \
    -D image_size=256 \
    --normal-window \
    --hide-scroll \
    --width 800 \
    --height 800 \
    --cache-file /dev/null)

[[ -z "$selection" ]] && exit 0

# Extract the filename from the selection
wallpaper=$(echo "$selection" | sed 's/^img:.*:text://')

# Pick a random transition
transition=${TRANSITIONS[$((RANDOM % ${#TRANSITIONS[@]}))]}

swww img "$WALLPAPER_DIR/$wallpaper" \
    --transition-type "$transition" \
    --transition-duration 2 \
    --transition-fps 60 \
    --transition-step 90

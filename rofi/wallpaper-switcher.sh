#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-switcher/thumbs"
STYLE="$HOME/.config/rofi/wallpaper-switcher.rasi"
TRANSITIONS=("simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "any" "outer" "random")

mkdir -p "$THUMB_DIR"
entries=""
while IFS= read -r file; do
  name=$(basename "$file")
  thumb="$THUMB_DIR/$name"
  if [[ ! -f "$thumb" || "$file" -nt "$thumb" ]]; then
    magick "$file" -resize 256x256^ -gravity center -extent 256x256 "$thumb" 2>/dev/null
  fi
  # Use full filename as key — no extension stripping, no ambiguous re-matching
  entries+="${name}\0icon\x1f${thumb}\n"
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
  -o -iname '*.webp' -o -iname '*.gif' \) |
  sort)

selection=$(printf '%b' "$entries" | rofi -dmenu \
  -p "󰋩  Wallpapers" \
  -theme "$STYLE" \
  -show-icons \
  -kb-move-char-back "" \
  -kb-move-char-forward "" \
  -kb-row-up "Alt+k,Up" \
  -kb-row-down "Alt+j,Down" \
  -kb-row-left "Alt+h,Left" \
  -kb-row-right "Alt+l,Right" \
  -kb-clear-line "Alt+c,slash")

[[ -z "$selection" ]] && exit 0

transition=${TRANSITIONS[$((RANDOM % ${#TRANSITIONS[@]}))]}

awww img "$WALLPAPER_DIR/$selection" \
  --transition-type "$transition" \
  --transition-duration 2 \
  --transition-fps 60 \
  --transition-step 90

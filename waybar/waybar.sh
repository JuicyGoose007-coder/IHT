#!/usr/bin/env sh

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

# Read saved layout (default: full)
layout_file="$HOME/.cache/theme-switcher/waybar-layout"
layout="full"
[ -f "$layout_file" ] && layout=$(cat "$layout_file")

# Pick config and style based on compositor + layout
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    case "$layout" in
        wsonly) config="config-hyprland-wsonly"; style="style-wsonly.css" ;;
        *)      config="config-hyprland"        ; style="style.css" ;;
    esac
elif pgrep -x niri >/dev/null; then
    case "$layout" in
        wsonly) config="config-niri-wsonly"; style="style-wsonly.css" ;;
        *)      config="config-niri"        ; style="style.css" ;;
    esac
else
    waybar &
    exit 0
fi

waybar -c "$HOME/.config/waybar/$config" -s "$HOME/.config/waybar/$style" &

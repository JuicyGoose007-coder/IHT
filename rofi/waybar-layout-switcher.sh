#!/usr/bin/env bash
#
# Waybar layout switcher — toggle between full and workspaces-only layouts.
# Auto-detects compositor (Hyprland / Niri) for the correct config files.
#

set -uo pipefail

exec 9>/tmp/waybar-layout-switcher.lock
flock -n 9 || exit 1
trap 'rm -f /tmp/waybar-layout-switcher.lock; exit' EXIT INT TERM

CACHE_DIR="$HOME/.cache/theme-switcher"
WAYBAR_LAYOUT_FILE="$CACHE_DIR/waybar-layout"
STYLE="$HOME/.config/rofi/waybar-layout-switcher.rasi"

mkdir -p "$CACHE_DIR"

get_waybar_layout() {
  [[ -f "$WAYBAR_LAYOUT_FILE" ]] && printf '%s' "$(cat "$WAYBAR_LAYOUT_FILE")" || printf 'full'
}

restart_waybar() {
  local layout config style
  layout=$(get_waybar_layout)

  if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    if [[ "$layout" == "wsonly" ]]; then
      config="config-hyprland-wsonly"
    else
      config="config-hyprland"
    fi
  else
    if [[ "$layout" == "wsonly" ]]; then
      config="config-niri-wsonly"
    else
      config="config-niri"
    fi
  fi

  style="style.css"
  [[ "$layout" == "wsonly" ]] && style="style-wsonly.css"

  pkill -x waybar 2>/dev/null || true
  while pgrep -x waybar >/dev/null 2>&1; do sleep 0.2; done
  waybar -c "$HOME/.config/waybar/$config" -s "$HOME/.config/waybar/$style" &
}

current_layout=$(get_waybar_layout)

if [[ "$current_layout" == "full" ]]; then
  entries="✓ Full Layout\n"
  entries+="  WS-Only Layout\n"
else
  entries="  Full Layout\n"
  entries+="✓ WS-Only Layout\n"
fi

selection=$(printf '%b' "$entries" | rofi -dmenu -i -p " Layout" -theme "$STYLE") || exit 1

case "$selection" in
  *"Full Layout")     printf 'full'   >"$WAYBAR_LAYOUT_FILE" ;;
  *"WS-Only Layout") printf 'wsonly' >"$WAYBAR_LAYOUT_FILE" ;;
  *) exit 0 ;;
esac

restart_waybar
notify-send -t 2000 "Waybar Layout" "Switched to: $selection" 2>/dev/null || true

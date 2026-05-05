#!/usr/bin/env bash
#
# System-wide theme switcher — generates Material You palettes from
# wallpapers via matugen, applies them to all desktop applications.
#

set -euo pipefail

# Prevent multiple instances
exec 9>/tmp/theme-switcher.lock
flock -n 9 || exit 1

# ── Dependencies ─────────────────────────────────────────────────────
for cmd in wallust jq; do
  command -v "$cmd" &>/dev/null || {
    notify-send -u critical "Theme Switcher" "Missing dependency: $cmd" 2>/dev/null
    exit 1
  }
done

# ── Directories ──────────────────────────────────────────────────────
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/theme-switcher"
THUMB_DIR="$CACHE_DIR/thumbs"
STYLE="$HOME/.config/rofi/theme-switcher.rasi"
TRANSITIONS=("simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "any" "outer" "random")

mkdir -p "$THUMB_DIR"

# ── Oxocarbon default palette ───────────────────────────────────────
oxo_BG0="#161616"
oxo_BG1="#262626"
oxo_BG2="#393939"
oxo_BG3="#525252"
oxo_FG0="#dde1e6"
oxo_FG1="#f2f4f8"
oxo_CYAN="#08bdba"
oxo_TEAL="#3ddbd9"
oxo_BLUE="#78a9ff"
oxo_LBLUE="#33b1ff"
oxo_PINK="#ee5396"
oxo_MAGENTA="#ff7eb6"
oxo_GREEN="#42be65"
oxo_PURPLE="#be95ff"
oxo_SKY="#82cfff"

load_oxocarbon() {
  BG0="$oxo_BG0"
  BG1="$oxo_BG1"
  BG2="$oxo_BG2"
  BG3="$oxo_BG3"
  FG0="$oxo_FG0"
  FG1="$oxo_FG1"
  ACCENT_CYAN="$oxo_CYAN"
  ACCENT_TEAL="$oxo_TEAL"
  ACCENT_BLUE="$oxo_BLUE"
  ACCENT_LBLUE="$oxo_LBLUE"
  ACCENT_PINK="$oxo_PINK"
  ACCENT_MAGENTA="$oxo_MAGENTA"
  ACCENT_GREEN="$oxo_GREEN"
  ACCENT_PURPLE="$oxo_PURPLE"
  ACCENT_SKY="$oxo_SKY"
}

# ── Color math helpers ──────────────────────────────────────────────
hex_to_rgb() {
  local hex="${1#\#}"
  R=$((16#${hex:0:2}))
  G=$((16#${hex:2:2}))
  B=$((16#${hex:4:2}))
}

rgb_to_hex() {
  printf '#%02x%02x%02x' "$1" "$2" "$3"
}

darken_color() {
  hex_to_rgb "$1"
  local pct=${2:-30}
  local r=$((R * (100 - pct) / 100))
  local g=$((G * (100 - pct) / 100))
  local b=$((B * (100 - pct) / 100))
  ((r < 0)) && r=0
  ((g < 0)) && g=0
  ((b < 0)) && b=0
  rgb_to_hex "$r" "$g" "$b"
}

lighten_color() {
  hex_to_rgb "$1"
  local pct=${2:-30}
  local r=$((R + (255 - R) * pct / 100))
  local g=$((G + (255 - G) * pct / 100))
  local b=$((B + (255 - B) * pct / 100))
  ((r > 255)) && r=255
  ((g > 255)) && g=255
  ((b > 255)) && b=255
  rgb_to_hex "$r" "$g" "$b"
}

# Helper: hue-preserving brightness floor — scales RGB so brightest channel >= target
brighten_floor() {
  local hex="${1#\#}" target="${2:-200}"
  local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
  local maxc=$r
  ((g > maxc)) && maxc=$g
  ((b > maxc)) && maxc=$b
  if ((maxc > 0 && maxc < target)); then
    r=$((r * target / maxc)); ((r > 255)) && r=255
    g=$((g * target / maxc)); ((g > 255)) && g=255
    b=$((b * target / maxc)); ((b > 255)) && b=255
  fi
  printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Helper: hex color to hex with alpha suffix (e.g. #161616 -> #161616e6)
hex_alpha() {
  local hex="${1#\#}"
  local alpha="$2"
  printf '#%s%s' "$hex" "$alpha"
}

# ── Color extraction (wallust — dark16 palette) ───────────────────
extract_palette() {
  local img="$1"
  local cache="$HOME/.cache/theme-switcher/palette.json"

  wallust run "$img" >/dev/null 2>&1 || {
    load_oxocarbon
    return
  }
  [[ -f "$cache" ]] || { load_oxocarbon; return; }

  # Pull all needed slots in one jq invocation (15 forks → 1)
  local bg_main bg_zero c8 c7 fg_raw c12 c11 c14 c13 c10 c9 c5 c3 c4
  {
    read -r bg_main; read -r bg_zero
    read -r c8;      read -r c7;      read -r fg_raw
    read -r c12;     read -r c11;     read -r c14
    read -r c13;     read -r c10;     read -r c9
    read -r c5;      read -r c3;      read -r c4
  } < <(jq -r '.background, .color0, .color8, .color7, .foreground,
               .color12, .color11, .color14, .color13, .color10,
               .color9, .color5, .color3, .color4' "$cache")

  # Pick darker of {background, color0} as BG0 so backdrop stays deepest.
  # Crude luminance: sum of RGB bytes; lower = darker.
  _lum() { local h="${1#\#}"; printf "%d" $((0x${h:0:2} + 0x${h:2:2} + 0x${h:4:2})); }
  if (( $(_lum "$bg_zero") < $(_lum "$bg_main") )); then
    BG0="$bg_zero"; BG1="$bg_main"
  else
    BG0="$bg_main"; BG1="$bg_zero"
  fi
  BG2="$c8"
  BG3="$c7"
  FG0="$c7"
  FG1="$fg_raw"
  ACCENT_PINK=$(brighten_floor "$c12" 220)
  ACCENT_GREEN=$(brighten_floor "$c11" 220)
  ACCENT_BLUE=$(brighten_floor "$c14" 220)
  ACCENT_PURPLE=$(brighten_floor "$c13" 220)
  ACCENT_CYAN=$(brighten_floor "$c10" 220)
  ACCENT_LBLUE=$(brighten_floor "$c9" 220)
  ACCENT_MAGENTA=$(brighten_floor "$c5" 220)
  ACCENT_TEAL=$(brighten_floor "$c3" 220)
  ACCENT_SKY=$(brighten_floor "$c4" 220)
  # Floor FG levels too so text reads on dark BGs
  FG0=$(brighten_floor "$FG0" 180)
  FG1=$(brighten_floor "$FG1" 230)

  # Validate — if any color is empty/null, fall back
  for c in "$BG0" "$BG1" "$BG2" "$BG3" "$FG0" "$FG1" \
    "$ACCENT_BLUE" "$ACCENT_LBLUE" "$ACCENT_PURPLE" \
    "$ACCENT_MAGENTA" "$ACCENT_CYAN" "$ACCENT_TEAL" \
    "$ACCENT_GREEN" "$ACCENT_PINK" "$ACCENT_SKY"; do
    if [[ -z "$c" || "$c" == "null" ]]; then
      load_oxocarbon
      return
    fi
  done
}

# ── Template generators ─────────────────────────────────────────────
generate_waybar() {
  local file="$HOME/.config/waybar/style.css"
  [[ -f "$file" ]] || return 0

  local header
  header=$(
    cat <<EOF
/* Theme: $THEME_NAME */
@define-color bg0     ${BG0};
@define-color bg1     ${BG1};
@define-color bg2     ${BG2};
@define-color bg3     ${BG3};
@define-color fg0     ${FG0};
@define-color fg1     ${FG1};
@define-color white   #ffffff;
@define-color cyan    ${ACCENT_CYAN};
@define-color teal    ${ACCENT_TEAL};
@define-color blue    ${ACCENT_BLUE};
@define-color pink    ${ACCENT_PINK};
@define-color lblue   ${ACCENT_LBLUE};
@define-color magenta ${ACCENT_MAGENTA};
@define-color green   ${ACCENT_GREEN};
@define-color purple  ${ACCENT_PURPLE};
@define-color sky     ${ACCENT_SKY};
EOF
  )
  # Keep everything after the @define-color block (line 18+)
  local body
  body=$(sed -n '18,$p' "$file")
  printf '%s\n\n%s\n' "$header" "$body" >"$file"
}

generate_rofi_colors() {
  cat >"$HOME/.config/rofi/colors.rasi" <<EOF
/* Generated by theme-switcher — do not edit manually */
* {
    /* Shared backgrounds / foregrounds */
    r-bg0:           $(hex_alpha "$BG0" "d9");
    r-bg1:           $(hex_alpha "$BG1" "d9");
    r-fg0:           ${FG0};
    r-fg1:           ${FG1};
    r-bg3:           ${BG3};

    /* Launcher */
    r-base:          ${BG0}ff;
    r-surface:       ${BG1}ff;
    r-overlay:       ${BG2}ff;
    r-muted:         ${BG3}ff;
    r-text:          ${FG1}ff;
    r-subtext:       ${FG0}ff;
    r-blue:          ${ACCENT_BLUE}ff;
    r-purple:        ${ACCENT_PURPLE}ff;
    r-teal:          ${ACCENT_TEAL}ff;
    r-blue-dim:      $(hex_alpha "$ACCENT_BLUE" "20");
    r-blue-border:   $(hex_alpha "$ACCENT_BLUE" "50");
    r-purple-dim:    $(hex_alpha "$ACCENT_PURPLE" "15");
    r-purple-border: $(hex_alpha "$ACCENT_PURPLE" "45");

    /* Wallpaper switcher */
    r-wp-accent:     ${ACCENT_PINK};
    r-wp-al:         ${ACCENT_MAGENTA};
    r-wp-b1:         $(hex_alpha "$ACCENT_PINK" "40");
    r-wp-b2:         $(hex_alpha "$ACCENT_MAGENTA" "59");
    r-wp-sel:        $(hex_alpha "$ACCENT_PINK" "26");
    r-wp-sel-b:      $(hex_alpha "$ACCENT_PINK" "80");
    r-wp-icon:       $(hex_alpha "$ACCENT_PINK" "19");

    /* Theme switcher */
    r-ts-accent:     ${ACCENT_BLUE};
    r-ts-al:         ${ACCENT_LBLUE};
    r-ts-b1:         $(hex_alpha "$ACCENT_BLUE" "40");
    r-ts-b2:         $(hex_alpha "$ACCENT_LBLUE" "59");
    r-ts-sel:        $(hex_alpha "$ACCENT_BLUE" "26");
    r-ts-sel-b:      $(hex_alpha "$ACCENT_BLUE" "80");
    r-ts-icon:       $(hex_alpha "$ACCENT_BLUE" "19");

    /* Power menu */
    r-pm-bg0:        $(hex_alpha "$BG0" "e6");
    r-pm-bg1:        $(hex_alpha "$BG1" "e6");
    r-pm-accent:     ${ACCENT_BLUE};
    r-pm-al:         ${ACCENT_LBLUE};
    r-pm-b1:         $(hex_alpha "$ACCENT_BLUE" "40");
    r-pm-b2:         $(hex_alpha "$ACCENT_LBLUE" "59");
    r-pm-sel:        $(hex_alpha "$ACCENT_LBLUE" "26");
    r-pm-sel-b:      $(hex_alpha "$ACCENT_LBLUE" "80");

    /* Keybinds (reuses launcher vars + extras) */
    r-subtle:        ${FG0}ff;
    r-pink:          ${ACCENT_PINK}ff;

    /* Notification center */
    r-nc-bg0:        $(hex_alpha "$BG0" "ee");
    r-nc-bg1:        $(hex_alpha "$BG1" "ee");
    r-nc-accent:     ${ACCENT_BLUE};
    r-nc-adim:       $(hex_alpha "$ACCENT_BLUE" "30");
    r-nc-aborder:    $(hex_alpha "$ACCENT_BLUE" "50");
    r-nc-muted:      ${BG3};
}
EOF
}

generate_rofi_app() {
  cat >"$HOME/.config/rofi/launcher.rasi" <<EOF
/* Theme: $THEME_NAME — app launcher */

configuration {
    show-icons:          true;
    display-drun:        "  Apps";
    drun-display-format: "{name}";
    icon-size:           48;
    hover-select:        true;
    me-select-entry:     "MousePrimary";
    me-accept-entry:     "MouseSecondary";
}

* {
    font:          "JetBrainsMono Nerd Font 11";

    base:          ${BG0}ff;
    surface:       ${BG1}ff;
    overlay:       ${BG2}ff;
    muted:         ${BG3}ff;
    text:          ${FG1}ff;
    subtext:       ${FG0}ff;
    blue:          ${ACCENT_BLUE}ff;
    purple:        ${ACCENT_PURPLE}ff;
    teal:          ${ACCENT_TEAL}ff;

    transparent:   #00000000;
    blue-dim:      $(hex_alpha "$ACCENT_BLUE" "20");
    blue-border:   $(hex_alpha "$ACCENT_BLUE" "50");
    purple-dim:    $(hex_alpha "$ACCENT_PURPLE" "15");
    purple-border: $(hex_alpha "$ACCENT_PURPLE" "45");
}

window {
    background-color: @transparent;
    border:           0;
    width:            620px;
    location:         center;
    anchor:           center;
}

mainbox {
    background-color: @surface;
    border-radius:    20px;
    border:           2px solid;
    border-color:     @blue-border;
    padding:          18px;
    spacing:          0;
    children:         [inputbar, listview];
}

inputbar {
    background-color: @surface;
    border-radius:    16px;
    border:           1px solid;
    border-color:     @purple-border;
    padding:          12px 16px;
    margin:           0 0 12px 0;
    children:         [prompt, entry];
    spacing:          10px;
}

prompt {
    background-color: @transparent;
    text-color:       @purple;
    font:             "JetBrainsMono Nerd Font Bold 12";
}

entry {
    background-color: @transparent;
    text-color:       @teal;
    cursor:           text;
    placeholder:      "Search applications…";
    placeholder-color: @muted;
}

listview {
    background-color: @transparent;
    columns:          1;
    lines:            8;
    scrollbar:        false;
    spacing:          4px;
    fixed-height:     true;
}

element {
    background-color: @transparent;
    border-radius:    12px;
    border:           1px solid;
    border-color:     @transparent;
    padding:          10px 14px;
    spacing:          14px;
    orientation:      horizontal;
}

element normal normal {
    background-color: @transparent;
    border-color:     @transparent;
}

element selected normal {
    background-color: @purple-dim;
    border-color:     @purple-border;
}

element normal urgent {
    background-color: @transparent;
}

element selected urgent {
    background-color: @blue-dim;
    border-color:     @blue-border;
}

element normal active {
    background-color: @transparent;
}

element selected active {
    background-color: @purple-dim;
    border-color:     @purple-border;
}

element-icon {
    background-color: @transparent;
    size:             42px;
    border-radius:    8px;
    vertical-align:   0.5;
}

element-text {
    background-color: @transparent;
    text-color:       @blue;
    font:             "JetBrainsMono Nerd Font Bold 13";
    vertical-align:   0.5;
}

element-text selected {
    text-color: @teal;
}
EOF
}

generate_wofi_app() {
  [[ -d "$HOME/.config/wofi" ]] || return 0
  cat >"$HOME/.config/wofi/style.css" <<EOF
/* Theme: $THEME_NAME — app launcher */

* {
    font-family: "Inter Medium", "Iosevka Term", "Font Awesome 6 Free", Roboto, sans-serif;
    font-size: 13px;
}

window {
    background-color: transparent;
    border: none;
}

#outer-box {
    margin: 0px;
    padding: 20px;
    background-color: alpha(${BG0}, 0.85);
    border-radius: 24px;
    border: 2px solid alpha(${ACCENT_BLUE}, 0.25);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.6);
}

#inner-box {
    background-color: transparent;
    border-radius: 20px;
}

#input {
    margin: 0px 4px 16px 4px;
    padding: 14px 18px;
    border-radius: 24px;
    border: 2px solid alpha(${ACCENT_PURPLE}, 0.35);
    background-color: alpha(${BG1}, 0.85);
    color: ${FG1};
    caret-color: ${ACCENT_LBLUE};
}

#input:focus {
    border-color: ${ACCENT_BLUE};
    background-color: alpha(${ACCENT_LBLUE}, 0.08);
}

#scroll {
    margin: 0px;
    background-color: transparent;
}

#entry {
    padding: 10px 14px;
    margin: 3px 2px;
    border-radius: 24px;
    background-color: alpha(${BG0}, 0.85);
    border: 1px solid transparent;
    transition: all 0.3s cubic-bezier(0.165, 0.84, 0.44, 1);
}

#entry:selected {
    background-color: alpha(${ACCENT_PURPLE}, 0.15);
    border: 1px solid alpha(${ACCENT_PURPLE}, 0.5);
    border-radius: 24px;
}

#text {
    padding: 8px 12px;
    color: ${FG0};
    font-size: 13px;
    font-weight: bold;
}

#text:selected {
    color: ${ACCENT_PURPLE};
    font-weight: bold;
}

#img {
    margin: 6px 14px 6px 6px;
    border-radius: 12px;
    background-color: alpha(${ACCENT_BLUE}, 0.1);
}
EOF
}

generate_wofi_wallpaper() {
  [[ -d "$HOME/.config/wofi" ]] || return 0
  cat >"$HOME/.config/wofi/wallpaper-switcher.css" <<EOF
/* Theme: $THEME_NAME — wallpaper switcher */

* {
    font-family: "Inter Medium", "Iosevka Term", "Font Awesome 6 Free", Roboto, sans-serif;
    font-size: 13px;
}

window {
    background-color: transparent;
    border: none;
}

#outer-box {
    margin: 0px;
    padding: 20px;
    background-color: alpha(${BG0}, 0.85);
    border-radius: 24px;
    border: 2px solid alpha(${ACCENT_PINK}, 0.25);
}

#inner-box {
    background-color: transparent;
    border-radius: 20px;
}

#input {
    margin: 0px 4px 16px 4px;
    padding: 14px 18px;
    border-radius: 24px;
    border: 2px solid alpha(${ACCENT_MAGENTA}, 0.35);
    background-color: alpha(${BG1}, 0.85);
    color: ${FG1};
    caret-color: ${ACCENT_MAGENTA};
}

#input:focus {
    border-color: ${ACCENT_PINK};
    background-color: alpha(${ACCENT_PINK}, 0.08);
}

#scroll {
    margin: 0px;
    background-color: transparent;
}

#entry {
    padding: 10px 14px;
    margin: 3px 2px;
    border-radius: 24px;
    background-color: alpha(${BG0}, 0.85);
    border: 1px solid transparent;
    transition: all 0.3s cubic-bezier(0.165, 0.84, 0.44, 1);
}

#entry:selected {
    background-color: alpha(${ACCENT_PINK}, 0.15);
    border: 1px solid alpha(${ACCENT_PINK}, 0.5);
    border-radius: 24px;
}

#text {
    padding: 8px 12px;
    color: ${FG0};
    font-size: 13px;
    font-weight: bold;
}

#text:selected {
    color: ${ACCENT_MAGENTA};
    font-weight: bold;
}

#img {
    margin: 6px 14px 6px 6px;
    border-radius: 14px;
    background-color: alpha(${ACCENT_PINK}, 0.1);
    min-width: 256px;
    min-height: 144px;
}
EOF
}

generate_wofi_theme() {
  [[ -d "$HOME/.config/wofi" ]] || return 0
  cat >"$HOME/.config/wofi/theme-switcher.css" <<EOF
/* Theme: $THEME_NAME — theme switcher */

* {
    font-family: "Inter Medium", "Iosevka Term", "Font Awesome 6 Free", Roboto, sans-serif;
    font-size: 13px;
}

window {
    background-color: transparent;
    border: none;
}

#outer-box {
    margin: 0px;
    padding: 20px;
    background-color: alpha(${BG0}, 0.85);
    border-radius: 24px;
    border: 2px solid alpha(${ACCENT_CYAN}, 0.25);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.6);
}

#inner-box {
    background-color: transparent;
    border-radius: 20px;
}

#input {
    margin: 0px 4px 16px 4px;
    padding: 14px 18px;
    border-radius: 24px;
    border: 2px solid alpha(${ACCENT_TEAL}, 0.35);
    background-color: alpha(${BG1}, 0.85);
    color: ${FG1};
    caret-color: ${ACCENT_TEAL};
}

#input:focus {
    border-color: ${ACCENT_CYAN};
    background-color: alpha(${ACCENT_CYAN}, 0.08);
}

#scroll {
    margin: 0px;
    background-color: transparent;
}

#entry {
    padding: 10px 14px;
    margin: 3px 2px;
    border-radius: 24px;
    background-color: alpha(${BG0}, 0.85);
    border: 1px solid transparent;
    transition: all 0.3s cubic-bezier(0.165, 0.84, 0.44, 1);
}

#entry:selected {
    background-color: alpha(${ACCENT_CYAN}, 0.15);
    border: 1px solid alpha(${ACCENT_CYAN}, 0.5);
    border-radius: 24px;
}

#text {
    padding: 8px 12px;
    color: ${FG0};
    font-size: 13px;
    font-weight: bold;
}

#text:selected {
    color: ${ACCENT_TEAL};
    font-weight: bold;
}

#img {
    margin: 6px 14px 6px 6px;
    border-radius: 14px;
    background-color: alpha(${ACCENT_CYAN}, 0.1);
    min-width: 256px;
    min-height: 144px;
}
EOF
}

generate_niri() {
  local file="$HOME/.config/niri/colors.kdl"
  [[ -d "$(dirname "$file")" ]] || return 0

  local inactive_tab
  inactive_tab=$(darken_color "$ACCENT_LBLUE" 50)

  cat >"$file" <<EOF
layout {

    focus-ring {
        active-color   "${ACCENT_LBLUE}"
        inactive-color "${BG0}"
        urgent-color   "${ACCENT_PINK}"
    }

    border {
        active-color   "${ACCENT_LBLUE}"
        inactive-color "${BG0}"
        urgent-color   "${ACCENT_PINK}"
    }

    shadow {
        color "#00000070"
    }

    tab-indicator {
        active-color   "${ACCENT_LBLUE}"
        inactive-color "${inactive_tab}"
        urgent-color   "${ACCENT_PINK}"
    }

    insert-hint {
        color "${ACCENT_LBLUE}80"
    }
}

recent-windows {
    highlight {
        active-color "${ACCENT_LBLUE}"
        urgent-color "${ACCENT_PINK}"
    }
}
EOF
}

generate_kitty() {
  local file="$HOME/.config/kitty/themes/noctalia.conf"
  [[ -d "$(dirname "$file")" ]] || return 0

  cat >"$file" <<EOF
color0 ${BG1}
color1 ${ACCENT_PINK}
color2 ${ACCENT_GREEN}
color3 ${ACCENT_SKY}
color4 ${ACCENT_LBLUE}
color5 ${ACCENT_MAGENTA}
color6 ${ACCENT_TEAL}
color7 ${FG0}
color8 ${BG2}
color9 ${ACCENT_PINK}
color10 ${ACCENT_GREEN}
color11 ${ACCENT_SKY}
color12 ${ACCENT_LBLUE}
color13 ${ACCENT_MAGENTA}
color14 ${ACCENT_TEAL}
color15 #ffffff
background ${BG0}
selection_foreground ${BG0}
cursor ${FG1}
cursor_text_color ${BG0}
foreground ${FG1}
selection_background ${FG1}
active_border_color ${ACCENT_LBLUE}
inactive_border_color ${ACCENT_GREEN}

active_tab_foreground   ${BG0}
active_tab_background   ${ACCENT_LBLUE}
inactive_tab_foreground ${FG0}
inactive_tab_background ${BG1}
cursor_trail_color      ${FG0}
EOF
}

generate_ghostty() {
  local file="$HOME/.config/ghostty/themes/noctalia"
  [[ -d "$(dirname "$file")" ]] || return 0

  cat >"$file" <<EOF
palette = 0=${BG1}
palette = 1=${ACCENT_PINK}
palette = 2=${ACCENT_GREEN}
palette = 3=${ACCENT_SKY}
palette = 4=${ACCENT_LBLUE}
palette = 5=${ACCENT_MAGENTA}
palette = 6=${ACCENT_TEAL}
palette = 7=${FG0}
palette = 8=${BG2}
palette = 9=${ACCENT_PINK}
palette = 10=${ACCENT_GREEN}
palette = 11=${ACCENT_SKY}
palette = 12=${ACCENT_LBLUE}
palette = 13=${ACCENT_MAGENTA}
palette = 14=${ACCENT_TEAL}
palette = 15=#ffffff
background = ${BG0}
foreground = ${FG1}
cursor-color = ${FG1}
cursor-text = ${BG0}
selection-background = ${FG1}
selection-foreground = ${BG0}
EOF
}

generate_gtk3() {
  local file="$HOME/.config/gtk-3.0/noctalia.css"
  [[ -d "$(dirname "$file")" ]] || return 0

  cat >"$file" <<EOF
/*
* GTK Colors (GTK3)
* Generated by theme-switcher — ${THEME_NAME}
*/

@define-color accent_color ${ACCENT_LBLUE};
@define-color accent_bg_color ${ACCENT_LBLUE};
@define-color accent_fg_color ${BG0};

@define-color destructive_bg_color ${ACCENT_PINK};
@define-color destructive_fg_color ${BG0};

@define-color error_bg_color ${ACCENT_PINK};
@define-color error_fg_color ${BG0};

@define-color window_bg_color ${BG0};
@define-color window_fg_color ${FG1};

@define-color view_bg_color ${BG0};
@define-color view_fg_color ${FG1};

@define-color headerbar_bg_color ${BG0};
@define-color headerbar_fg_color ${FG1};
@define-color headerbar_backdrop_color @window_bg_color;

@define-color popover_bg_color ${BG1};
@define-color popover_fg_color ${FG1};

@define-color card_bg_color ${BG1};
@define-color card_fg_color ${FG1};

@define-color dialog_bg_color ${BG0};
@define-color dialog_fg_color ${FG1};

@define-color overview_bg_color ${BG1};
@define-color overview_fg_color ${FG1};

@define-color sidebar_bg_color ${BG1};
@define-color sidebar_fg_color ${FG1};
@define-color sidebar_backdrop_color @window_bg_color;
@define-color sidebar_border_color @window_bg_color;

@define-color secondary_sidebar_bg_color ${BG0};
@define-color secondary_sidebar_fg_color ${FG1};

/* Backdrop/unfocused states */
@define-color theme_unfocused_fg_color @window_fg_color;
@define-color theme_unfocused_text_color @view_fg_color;
@define-color theme_unfocused_bg_color @window_bg_color;
@define-color theme_unfocused_base_color @window_bg_color;
@define-color theme_unfocused_selected_bg_color @accent_bg_color;
@define-color theme_unfocused_selected_fg_color @accent_fg_color;
EOF
}

generate_gtk4() {
  local file="$HOME/.config/gtk-4.0/noctalia.css"
  [[ -d "$(dirname "$file")" ]] || return 0

  local warn_bg warn_fg success_bg success_fg
  warn_bg=$(darken_color "$ACCENT_PURPLE" 60)
  warn_fg=$(lighten_color "$ACCENT_PURPLE" 40)
  success_bg=$(darken_color "$ACCENT_GREEN" 60)
  success_fg=$(lighten_color "$ACCENT_GREEN" 40)

  cat >"$file" <<EOF
/*
* GTK Colors (GTK4)
* Generated by theme-switcher — ${THEME_NAME}
*/

@define-color accent_color ${ACCENT_LBLUE};
@define-color accent_bg_color ${ACCENT_LBLUE};
@define-color accent_fg_color ${BG0};

@define-color destructive_bg_color ${ACCENT_PINK};
@define-color destructive_fg_color ${BG0};

@define-color error_bg_color ${ACCENT_PINK};
@define-color error_fg_color ${BG0};

@define-color window_bg_color ${BG0};
@define-color window_fg_color ${FG1};

@define-color view_bg_color ${BG0};
@define-color view_fg_color ${FG1};

@define-color headerbar_bg_color ${BG0};
@define-color headerbar_fg_color ${FG1};
@define-color headerbar_backdrop_color @window_bg_color;

@define-color popover_bg_color ${BG1};
@define-color popover_fg_color ${FG1};

@define-color card_bg_color ${BG1};
@define-color card_fg_color ${FG1};

@define-color dialog_bg_color ${BG0};
@define-color dialog_fg_color ${FG1};

@define-color overview_bg_color ${BG1};
@define-color overview_fg_color ${FG1};

@define-color sidebar_bg_color ${BG1};
@define-color sidebar_fg_color ${FG1};
@define-color sidebar_backdrop_color @window_bg_color;
@define-color sidebar_border_color @window_bg_color;

@define-color secondary_sidebar_bg_color ${BG0};
@define-color secondary_sidebar_fg_color ${FG1};

/* Backdrop/unfocused states */
@define-color theme_unfocused_fg_color @window_fg_color;
@define-color theme_unfocused_text_color @view_fg_color;
@define-color theme_unfocused_bg_color @window_bg_color;
@define-color theme_unfocused_base_color @window_bg_color;
@define-color theme_unfocused_selected_bg_color @accent_bg_color;
@define-color theme_unfocused_selected_fg_color @accent_fg_color;

:root {
    --accent-color: ${ACCENT_LBLUE};
    --accent-bg-color: ${ACCENT_LBLUE};
    --accent-fg-color: ${BG0};

    --destructive-bg-color: ${ACCENT_PINK};
    --destructive-fg-color: ${BG0};

    --error-bg-color: ${ACCENT_PINK};
    --error-fg-color: ${BG0};
    --error-color: ${ACCENT_PINK};

    --window-bg-color: ${BG0};
    --window-fg-color: ${FG1};

    --view-bg-color: ${BG0};
    --view-fg-color: ${FG1};

    --headerbar-bg-color: ${BG0};
    --headerbar-fg-color: ${FG1};
    --headerbar-backdrop-color: @window_bg_color;

    --popover-bg-color: ${BG1};
    --popover-fg-color: ${FG1};

    --card-bg-color: ${BG1};
    --card-fg-color: ${FG1};

    --dialog-bg-color: ${BG0};
    --dialog-fg-color: ${FG1};

    --overview-bg-color: ${BG1};
    --overview-fg-color: ${FG1};

    --sidebar-bg-color: ${BG1};
    --sidebar-fg-color: ${FG1};
    --sidebar-backdrop-color: @window_bg_color;
    --sidebar-border-color: @window_bg_color;

    --warning-bg-color: ${warn_bg};
    --warning-fg-color: ${warn_fg};
    --warning-color: ${ACCENT_PURPLE};

    --success-color: ${ACCENT_GREEN};
    --success-bg-color: ${success_bg};
    --success-fg-color: ${success_fg};

    --shade-color: rgba(0, 0, 0, 0.36);
}
EOF
}

generate_qt() {
  local highlight highlight_text
  highlight=$(darken_color "$ACCENT_LBLUE" 50)
  highlight_text=$(lighten_color "$ACCENT_LBLUE" 70)

  local palette_line="${FG1}, ${BG0}, #ffffff, #cacaca, #9f9f9f, #b8b8b8, ${FG1}, #ffffff, ${FG1}, ${BG0}, ${BG0}, #000000, ${highlight}, ${highlight_text}, ${ACCENT_GREEN}, ${ACCENT_LBLUE}, ${BG1}, ${BG0}, ${BG1}, ${FG1}, ${FG1}, ${ACCENT_LBLUE}"

  for dir in "$HOME/.config/qt5ct/colors" "$HOME/.config/qt6ct/colors"; do
    [[ -d "$dir" ]] || continue
    cat >"$dir/noctalia.conf" <<EOF
[ColorScheme]
#https://doc.qt.io/archives/qt-5.15/qpalette.html
# windowText,button,light,midlight,dark,mid,text,brightText,buttonText,base,window,shadow,highlight,highlightedText,link,linkVisited,alternateBase,NO_IDEA,toolTipBase,toolTipText,placeholderText,accent
active_colors=${palette_line}
disabled_colors=${palette_line}
inactive_colors=${palette_line}
EOF
  done
}

generate_alacritty() {
  local file="$HOME/.config/alacritty/themes/noctalia.toml"
  [[ -d "$(dirname "$file")" ]] || return 0

  cat >"$file" <<EOF
# Colors (Noctalia — $THEME_NAME)

[colors.bright]
black = '${BG3}'
blue = '${ACCENT_LBLUE}'
cyan = '${ACCENT_TEAL}'
green = '$(lighten_color "$ACCENT_GREEN" 15)'
magenta = '${ACCENT_MAGENTA}'
red = '$(lighten_color "$ACCENT_PINK" 15)'
white = '#f0f6fc'
yellow = '${ACCENT_SKY}'

[colors.cursor]
cursor = '${FG1}'
text = '${BG0}'

[colors.normal]
black = '${BG2}'
blue = '${ACCENT_BLUE}'
cyan = '${ACCENT_CYAN}'
green = '${ACCENT_GREEN}'
magenta = '${ACCENT_PURPLE}'
red = '${ACCENT_PINK}'
white = '${FG0}'
yellow = '$(darken_color "$ACCENT_SKY" 15)'

[colors.primary]
background = '${BG0}'
foreground = '${FG1}'

[colors.selection]
background = '${ACCENT_BLUE}'
text = '${FG1}'
EOF
}

generate_mako() {
  local file="$HOME/.config/mako/config"
  [[ -f "$file" ]] || return 0

  local bg_alpha fg_col border_col
  bg_alpha="${BG1}dd"
  fg_col="${FG0}"
  border_col="${BG3}"

  sed -i \
    -e "s/^background-color=.*/background-color=${bg_alpha}/" \
    -e "s/^text-color=.*/text-color=${fg_col}/" \
    -e "s/^border-color=.*/border-color=${border_col}/" \
    "$file"
}

generate_btop() {
  local dir="$HOME/.config/btop/themes"
  [[ -d "$HOME/.config/btop" ]] || return 0
  mkdir -p "$dir"

  cat >"$dir/noctalia.theme" <<EOF
# Theme: $THEME_NAME — generated by theme-switcher

# Main bg and target for rounded corners
theme[main_bg]="${BG0}"

# Main text color
theme[main_fg]="${FG0}"

# Title color for boxes
theme[title]="${FG1}"

# Highlight color for keyboard shortcuts
theme[hi_fg]="${ACCENT_BLUE}"

# Background color of selected item in processes box
theme[selected_bg]="${BG2}"

# Foreground color of selected item in processes box
theme[selected_fg]="${ACCENT_LBLUE}"

# Color of inactive/disabled text
theme[inactive_fg]="${BG3}"

# Color of text appearing on top of graphs
theme[graph_text]="${FG0}"

# Misc colors for processes box
theme[proc_misc]="${ACCENT_CYAN}"

# Cpu box outline color
theme[cpu_box]="${BG2}"

# Memory/disks box outline color
theme[mem_box]="${BG2}"

# Net box outline color
theme[net_box]="${BG2}"

# Processes box outline color
theme[proc_box]="${BG2}"

# Box divider line and target for curved corners
theme[div_line]="${BG3}"

# Temperature graph colors
theme[temp_start]="${ACCENT_GREEN}"
theme[temp_mid]="${ACCENT_SKY}"
theme[temp_end]="${ACCENT_PINK}"

# CPU graph colors
theme[cpu_start]="${ACCENT_CYAN}"
theme[cpu_mid]="${ACCENT_BLUE}"
theme[cpu_end]="${ACCENT_PURPLE}"

# Mem/Disk free meter
theme[free_start]="${ACCENT_GREEN}"
theme[free_mid]="${ACCENT_TEAL}"
theme[free_end]="${ACCENT_CYAN}"

# Mem/Disk cached meter
theme[cached_start]="${ACCENT_LBLUE}"
theme[cached_mid]="${ACCENT_BLUE}"
theme[cached_end]="${ACCENT_PURPLE}"

# Mem/Disk available meter
theme[available_start]="${ACCENT_TEAL}"
theme[available_mid]="${ACCENT_CYAN}"
theme[available_end]="${ACCENT_BLUE}"

# Mem/Disk used meter
theme[used_start]="${ACCENT_PINK}"
theme[used_mid]="${ACCENT_MAGENTA}"
theme[used_end]="${ACCENT_PURPLE}"

# Download graph colors
theme[download_start]="${ACCENT_CYAN}"
theme[download_mid]="${ACCENT_BLUE}"
theme[download_end]="${ACCENT_PURPLE}"

# Upload graph colors
theme[upload_start]="${ACCENT_GREEN}"
theme[upload_mid]="${ACCENT_TEAL}"
theme[upload_end]="${ACCENT_CYAN}"

# Process box color gradient for threads, mem and cpu usage
theme[process_start]="${ACCENT_BLUE}"
theme[process_mid]="${ACCENT_PURPLE}"
theme[process_end]="${ACCENT_PINK}"
EOF

  # Set btop to use our theme
  local conf="$HOME/.config/btop/btop.conf"
  if [[ -f "$conf" ]]; then
    sed -i 's/^color_theme = .*/color_theme = "noctalia"/' "$conf"
  fi
}

generate_tmux() {
  local file="$HOME/.config/tmux/tmux.conf"
  [[ -f "$file" ]] || return 0

  # Replace the theme block (lines 1-54: palette comment through window-status-separator)
  local theme_block
  theme_block=$(
    cat <<TMUXEOF
# Palette ($THEME_NAME) — generated by theme-switcher
#   bg=${BG0}  bg1=${BG1}  bg2=${BG2}  bg3=${BG3}
#   fg=${FG1}  fg1=${FG0}
#   purple=${ACCENT_PURPLE}  blue=${ACCENT_BLUE}  pink=${ACCENT_PINK}
#   teal=${ACCENT_CYAN}  green=${ACCENT_GREEN}  red=${ACCENT_PINK}

# Theme
set-option -g status-style bg=${BG1},fg=${ACCENT_PURPLE}

# default window title colors
set-window-option -g window-status-style fg=${FG0},bg=default,dim

# active window title colors
set-window-option -g window-status-current-style fg=${ACCENT_PURPLE},bg=default,bright

# pane border
set-option -g pane-border-style fg=${BG2}
set-option -g pane-active-border-style fg=${ACCENT_PURPLE}

# message text
set-option -g message-style bg=${BG1},fg=${ACCENT_PINK}

# pane number display
set-option -g display-panes-active-colour "${ACCENT_BLUE}"
set-option -g display-panes-colour "${ACCENT_PURPLE}"

# clock
set-window-option -g clock-mode-colour "${ACCENT_GREEN}"


set -g status-interval 1
set -g status-justify centre
set -g status-left-length 80
set -g status-right-length 80

# Powerline status bar (matches p10k rainbow style)
# Left: [os_icon] > [session] > [window]
set -g status-left '\\
#[fg=${FG1},bg=${BG1}] 󰣇 #[fg=${BG1},bg=${ACCENT_BLUE}]\\
#[fg=${BG0},bg=${ACCENT_BLUE},bold] #S #[fg=${ACCENT_BLUE},bg=${BG1}]\\
#[none]'

# Right: [pane] < [date] < [time]
set -g status-right '\\
#[fg=${BG3},bg=${BG1}]\\
#[fg=${FG1},bg=${BG3}] %Y-%m-%d \\
#[fg=${ACCENT_PURPLE},bg=${BG3}]\\
#[fg=${BG0},bg=${ACCENT_PURPLE}] %I:%M %p \\
#[fg=${BG1},bg=${ACCENT_PURPLE}]'

# Window status (center)
set -g window-status-format '#[fg=${BG1},bg=${BG2}]#[fg=${FG0},bg=${BG2}] #I:#W #[fg=${BG2},bg=${BG1}]'
set -g window-status-current-format '#[fg=${BG1},bg=${ACCENT_GREEN}]#[fg=${BG0},bg=${ACCENT_GREEN},bold] #I:#W #[fg=${ACCENT_GREEN},bg=${BG1}]'
set -g window-status-separator ' '
TMUXEOF
  )

  # Replace from line 1 up to and including "window-status-separator" line
  local rest
  rest=$(sed -n '/^# C-b is not acceptable/,$p' "$file")

  # Also update copy-mode match styles if present
  rest=$(echo "$rest" | sed \
    -e "s/copy-mode-match-style \"bg=[^\"]*\"/copy-mode-match-style \"bg=${ACCENT_PURPLE},fg=${BG0}\"/" \
    -e "s/copy-mode-current-match-style \"bg=[^\"]*\"/copy-mode-current-match-style \"bg=${ACCENT_PINK},fg=${BG0},bold\"/")

  printf '%s\n\n%s\n' "$theme_block" "$rest" >"$file"
}

generate_swaylock() {
  local file="$HOME/.config/swaylock/config"
  [[ -f "$file" ]] || return 0

  # Strip leading # for swaylock (it uses bare hex)
  local bg0="${BG0#\#}" bg1="${BG1#\#}" bg2="${BG2#\#}" bg3="${BG3#\#}"
  local fg0="${FG0#\#}" fg1="${FG1#\#}"
  local blue="${ACCENT_BLUE#\#}" green="${ACCENT_GREEN#\#}"
  local pink="${ACCENT_PINK#\#}" purple="${ACCENT_PURPLE#\#}"

  sed -i \
    -e "s/^ring-color=.*/ring-color=${bg3}/" \
    -e "s/^key-hl-color=.*/key-hl-color=${green}/" \
    -e "s/^line-color=.*/line-color=${bg0}/" \
    -e "s/^separator-color=.*/separator-color=${bg2}/" \
    -e "s/^inside-color=.*/inside-color=${bg1}/" \
    -e "s/^bs-hl-color=.*/bs-hl-color=${pink}/" \
    -e "s/^layout-bg-color=.*/layout-bg-color=${bg1}/" \
    -e "s/^layout-border-color=.*/layout-border-color=${bg3}/" \
    -e "s/^layout-text-color=.*/layout-text-color=${fg0}/" \
    -e "s/^text-color=.*/text-color=${fg0}/" \
    "$file"
}

generate_wlogout() {
  local file="$HOME/.config/wlogout/style.css"
  [[ -f "$file" ]] || return 0

  cat >"$file" <<EOF
/* Theme: $THEME_NAME — generated by theme-switcher */

* {
	background-image: none;
	box-shadow: none;
}

window {
	background-color: rgba(${BG0_R}, ${BG0_G}, ${BG0_B}, 0.9);
}

button {
    border-radius: 0;
    border-color: ${BG2};
	text-decoration-color: ${FG1};
    color: ${FG1};
	background-color: ${BG1};
	border-style: solid;
	border-width: 1px;
	background-repeat: no-repeat;
	background-position: center;
	background-size: 25%;
}

button:focus, button:active, button:hover {
	background-color: ${ACCENT_PURPLE};
	outline-style: none;
}

#lock {
    background-image: image(url("/usr/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
}

#logout {
    background-image: image(url("/usr/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
}

#suspend {
    background-image: image(url("/usr/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
}

#hibernate {
    background-image: image(url("/usr/share/wlogout/icons/hibernate.png"), url("/usr/local/share/wlogout/icons/hibernate.png"));
}

#shutdown {
    background-image: image(url("/usr/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
}

#reboot {
    background-image: image(url("/usr/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
}
EOF
}

generate_starship() {
  local file="$HOME/.config/starship/starship.toml"
  [[ -f "$file" ]] || return 0

  # Update palette values
  sed -i \
    -e "s/^crust = .*/crust = \"${BG0}\"/" \
    -e "s/^mantle = .*/mantle = \"${BG0}\"/" \
    -e "s/^base = .*/base = \"${BG1}\"/" \
    -e "s/^surface0 = .*/surface0 = \"${BG2}\"/" \
    -e "s/^surface1 = .*/surface1 = \"${BG3}\"/" \
    -e "s/^surface2 = .*/surface2 = \"$(lighten_color "$BG3" 15)\"/" \
    -e "s/^overlay0 = .*/overlay0 = \"${BG3}\"/" \
    -e "s/^overlay1 = .*/overlay1 = \"$(lighten_color "$BG3" 15)\"/" \
    -e "s/^overlay2 = .*/overlay2 = \"$(lighten_color "$BG3" 30)\"/" \
    -e "s/^text = .*/text = \"${FG1}\"/" \
    -e "s/^subtext0 = .*/subtext0 = \"${FG0}\"/" \
    -e "s/^subtext1 = .*/subtext1 = \"${FG1}\"/" \
    -e "s/^rosewater = .*/rosewater = \"${FG1}\"/" \
    -e "s/^flamingo = .*/flamingo = \"${ACCENT_MAGENTA}\"/" \
    -e "s/^pink = .*/pink = \"${ACCENT_MAGENTA}\"/" \
    -e "s/^mauve = .*/mauve = \"${ACCENT_PURPLE}\"/" \
    -e "s/^red = .*/red = \"${ACCENT_PINK}\"/" \
    -e "s/^maroon = .*/maroon = \"${ACCENT_MAGENTA}\"/" \
    -e "s/^peach = .*/peach = \"${ACCENT_MAGENTA}\"/" \
    -e "s/^yellow = .*/yellow = \"$(lighten_color "$ACCENT_MAGENTA" 20)\"/" \
    -e "s/^green = .*/green = \"${ACCENT_GREEN}\"/" \
    -e "s/^teal = .*/teal = \"${ACCENT_TEAL}\"/" \
    -e "s/^sky = .*/sky = \"${ACCENT_SKY}\"/" \
    -e "s/^sapphire = .*/sapphire = \"${ACCENT_BLUE}\"/" \
    -e "s/^blue = .*/blue = \"${ACCENT_BLUE}\"/" \
    -e "s/^lavender = .*/lavender = \"${ACCENT_PURPLE}\"/" \
    "$file"
}

generate_yazi() {
  local file="$HOME/.config/yazi/flavors/noctalia.yazi/flavor.toml"
  [[ -f "$file" ]] || return 0

  # Derived colors
  local marker_dark count_light perm_sep_dark orphan_fg orphan_bg
  marker_dark=$(darken_color "$ACCENT_PURPLE" 50)
  count_light=$(lighten_color "$ACCENT_PURPLE" 40)
  perm_sep_dark=$(darken_color "$ACCENT_BLUE" 60)
  orphan_fg=$(lighten_color "$ACCENT_PINK" 40)
  orphan_bg=$(darken_color "$ACCENT_PINK" 60)

  # Extract the icon section (from "# : Icons" onward) — structure is stable
  local icons
  icons=$(sed -n '/^# : Icons/,$p' "$file")

  # Write the full UI template, then append icons with color replaced
  cat >"$file" <<EOF
# : Manager [[[

[mgr]
cwd = { fg = "${FG1}" }

# Find
find_keyword = { fg = "${ACCENT_PINK}", bold = true, italic = true, underline = true }
find_position = { fg = "${ACCENT_PINK}", bold = true, italic = true }

# Marker
marker_copied = { fg = "${marker_dark}", bg = "${marker_dark}" }
marker_cut = { fg = "${marker_dark}", bg = "${marker_dark}" }
marker_marked = { fg = "${ACCENT_PINK}", bg = "${ACCENT_PINK}" }
marker_selected = { fg = "${ACCENT_PURPLE}", bg = "${ACCENT_PURPLE}" }

# Count
count_copied = { fg = "${count_light}", bg = "${marker_dark}" }
count_cut = { fg = "${count_light}", bg = "${marker_dark}" }
count_selected = { fg = "${BG0}", bg = "${ACCENT_PURPLE}" }

# Border
border_style  = { fg = "${ACCENT_LBLUE}" }

# : ]]]


# : Status [[[

[status]
overall = { fg = "${ACCENT_LBLUE}" }
sep_left  = { open = "", close = "" }
sep_right = { open = "", close = "" }

# Progress
progress_label = { bold = true }
progress_normal = { fg = "${ACCENT_LBLUE}", bg = "${BG0}" }
progress_error = { fg = "${ACCENT_PINK}", bg = "${BG0}" }

# Permissions
perm_type = { fg = "${ACCENT_GREEN}" }
perm_write = { fg = "${ACCENT_PURPLE}" }
perm_exec = { fg = "${ACCENT_PINK}" }
perm_read = { fg = "${marker_dark}" }
perm_sep = { fg = "${perm_sep_dark}" }

# : ]]]


# : Mode [[[

[mode]

normal_main = { bg = "${ACCENT_LBLUE}", fg = "${BG0}", bold = true }
normal_alt  = { bg = "${BG1}", fg = "${FG0}" }

select_main = { bg = "${ACCENT_GREEN}", fg = "${BG0}", bold = true }
select_alt  = { bg = "${BG1}", fg = "${FG0}" }

unset_main = { bg = "${ACCENT_PURPLE}", fg = "${BG0}", bold = true }
unset_alt  = { bg = "${BG1}", fg = "${FG0}" }

# : ]]]


# : Input [[[

[input]
border = { fg = "${ACCENT_LBLUE}" }
title = {}
value = { fg = "${FG1}" }
selected = { reversed = true }

# : ]]]


# : Tabs [[[

[tabs]
active = { fg = "${BG0}", bold = true, bg = "${ACCENT_LBLUE}" }
inactive = { fg = "${ACCENT_GREEN}", bg = "${BG0}" }
sep_inner = { open = "", close = "" }

# : ]]]


# : Completion [[[

[cmp]
border = { fg = "${ACCENT_LBLUE}", bg = "${BG0}" }

# : ]]]


# : Tasks [[[

[tasks]
border = { fg = "${ACCENT_LBLUE}" }
title = {}
hovered = { fg = "${marker_dark}", underline = true }

# : ]]]


# : Which [[[

[which]
cols = 3
mask = { bg = "${BG0}" }
cand = { fg = "${ACCENT_LBLUE}" }
rest = { fg = "${BG0}" }
desc = { fg = "${FG1}" }
separator = " ▶ "
separator_style = { fg = "${FG1}" }

# : ]]]

# : Spotter [[[

[spot]
border   = { fg = "${ACCENT_LBLUE}" }
title    = { fg = "${ACCENT_LBLUE}" }
tbl_col  = { fg = "${FG1}" }
tbl_cell = { fg = "${FG1}", bg = "${BG0}" }

# : ]]]


# : Help [[[

[help]
on = { fg = "${FG1}" }
run = { fg = "${FG1}" }
hovered = { reversed = true, bold = true }
footer = { fg = "${BG0}", bg = "${ACCENT_GREEN}" }

# : ]]]


# : Notify [[[

[notify]
title_info = { fg = "${ACCENT_PURPLE}" }
title_warn = { fg = "${ACCENT_LBLUE}" }
title_error = { fg = "${ACCENT_PINK}" }

# : ]]]


# : File-specific styles [[[

[filetype]

rules = [
    # Images
    { mime = "image/*", fg = "${ACCENT_TEAL}" },

    # Media
    { mime = "{audio,video}/*", fg = "${ACCENT_SKY}" },

    # Archives
    { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "${ACCENT_MAGENTA}" },

    # Documents
    { mime = "application/{pdf,doc,rtf}", fg = "${ACCENT_GREEN}" },

    # Special files
    { mime = "*", is = "orphan", fg = "${orphan_fg}", bg = "${orphan_bg}" },
    { mime = "application/*exec*", fg = "${ACCENT_PINK}" },

    # Fallback
    { url = "*", fg = "${FG1}" },
    { url = "*/", fg = "${ACCENT_LBLUE}" },
]

# : ]]]

EOF

  # Append the icon section with all fg colors replaced to current ACCENT_LBLUE
  echo "$icons" | sed "s/fg = \"#[0-9a-fA-F]\{6\}\"/fg = \"${ACCENT_LBLUE}\"/g" >>"$file"
}

current_wallpaper() {
  local wp
  wp=$(awww query 2>/dev/null | awk -F'image: ' '/image: /{print $2; exit}')
  if [[ -z "$wp" || ! -f "$wp" ]]; then
    wp=$(find "$HOME/Pictures/wallpapers" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
         -o -iname '*.webp' \) | sort | head -1)
  fi
  printf '%s' "$wp"
}

generate_hyprlock() {
  local file="$HOME/.config/hypr/hyprlock.conf"
  [[ -d "$(dirname "$file")" ]] || return 0

  local wp
  wp=$(current_wallpaper)
  # Skip rewrite if no wallpaper resolvable — empty path = is rejected by hyprlock
  [[ -n "$wp" ]] || return 0

  cat >"$file" <<EOF
# Generated by theme-switcher — ${THEME_NAME}
# Do not edit manually. Edit theme-switcher.sh:generate_hyprlock instead.

general {
    hide_cursor = true
    grace = 0
    disable_loading_bar = true
    ignore_empty_input = true
}

background {
    monitor =
    path = ${wp}
    blur_passes = 2
    blur_size = 6
    noise = 0.0117
    contrast = 1.0
    brightness = 0.85
    vibrancy = 0.2
    vibrancy_darkness = 0.0
}

# Clock (h:MM AM/PM)
label {
    monitor =
    text = cmd[update:1000] echo "\$(date +"%-I:%M %p")"
    color = rgba(${FG1_R}, ${FG1_G}, ${FG1_B}, 1.0)
    font_size = 90
    font_family = JetBrainsMono Nerd Font
    position = 0, 300
    halign = center
    valign = center
}

# Date
label {
    monitor =
    text = cmd[update:60000] echo "\$(date +"%A, %B %d")"
    color = rgba(${FG0_R}, ${FG0_G}, ${FG0_B}, 0.9)
    font_size = 22
    font_family = JetBrainsMono Nerd Font
    position = 0, 220
    halign = center
    valign = center
}

# Username
label {
    monitor =
    text =   \$USER
    color = rgba(${BLUE_R}, ${BLUE_G}, ${BLUE_B}, 0.95)
    font_size = 16
    font_family = JetBrainsMono Nerd Font
    position = 0, -50
    halign = center
    valign = center
}

# Input field (minimal pill)
input-field {
    monitor =
    size = 280, 50
    outline_thickness = 2
    dots_size = 0.25
    dots_spacing = 0.4
    dots_center = true
    outer_color = rgba(${BLUE_R}, ${BLUE_G}, ${BLUE_B}, 0.5)
    inner_color = rgba(${BG0_R}, ${BG0_G}, ${BG0_B}, 0.7)
    font_color = rgba(${FG1_R}, ${FG1_G}, ${FG1_B}, 1.0)
    fade_on_empty = false
    placeholder_text = <i>password</i>
    hide_input = false
    rounding = 25
    check_color = rgba(${LBLUE_R}, ${LBLUE_G}, ${LBLUE_B}, 0.85)
    fail_color = rgba(${PINK_R}, ${PINK_G}, ${PINK_B}, 0.85)
    fail_text = <b>\$FAIL</b> <i>fail(s)</i> — try again
    fail_transition = 200
    capslock_color = rgba(${MAGENTA_R}, ${MAGENTA_G}, ${MAGENTA_B}, 0.85)
    position = 0, -120
    halign = center
    valign = center
}
EOF
}

generate_shell_colors() {
  cat >"$CACHE_DIR/colors.sh" <<EOF
# Generated by theme-switcher — do not edit manually
THEME_COLOR_KEY="${ACCENT_BLUE}"
THEME_COLOR_DESC="${FG0}"
THEME_COLOR_HEADER="${ACCENT_CYAN}"
EOF
}

generate_all() {
  # Compute RGB components (used by wlogout, hyprlock)
  hex_to_rgb "$BG0";            BG0_R=$R; BG0_G=$G; BG0_B=$B
  hex_to_rgb "$FG0";             FG0_R=$R; FG0_G=$G; FG0_B=$B
  hex_to_rgb "$FG1";             FG1_R=$R; FG1_G=$G; FG1_B=$B
  hex_to_rgb "$ACCENT_BLUE";     BLUE_R=$R; BLUE_G=$G; BLUE_B=$B
  hex_to_rgb "$ACCENT_LBLUE";    LBLUE_R=$R; LBLUE_G=$G; LBLUE_B=$B
  hex_to_rgb "$ACCENT_PINK";     PINK_R=$R; PINK_G=$G; PINK_B=$B
  hex_to_rgb "$ACCENT_MAGENTA";  MAGENTA_R=$R; MAGENTA_G=$G; MAGENTA_B=$B

  generate_shell_colors
  generate_waybar
  generate_rofi_colors
  generate_wofi_app
  generate_wofi_wallpaper
  generate_wofi_theme
  generate_niri
  generate_kitty
  generate_ghostty
  generate_gtk3
  generate_gtk4
  generate_qt
  generate_alacritty
  generate_mako
  generate_btop
  generate_tmux
  generate_swaylock
  generate_hyprlock
  generate_wlogout
  generate_starship
  generate_yazi
}

# ── Reload running applications ─────────────────────────────────────
reload_all() {
  # Waybar: SIGUSR2 reloads CSS
  pkill -SIGUSR2 waybar 2>/dev/null || true

  # Niri: reload config
  niri msg action load-config-file 2>/dev/null || true

  # Ghostty: live update existing surfaces via OSC, plus SIGUSR2 for new windows.
  # SIGUSR2 alone only applies palette/theme to *new* surfaces in 1.x; OSC pokes
  # each open pty so currently-running shells repaint future output too.
  ghostty_live_update() {
    local osc=""
    osc+="\033]11;${BG0}\033\\"
    osc+="\033]10;${FG1}\033\\"
    osc+="\033]12;${FG1}\033\\"
    osc+="\033]4;0;${BG1}\033\\"
    osc+="\033]4;1;${ACCENT_PINK}\033\\"
    osc+="\033]4;2;${ACCENT_GREEN}\033\\"
    osc+="\033]4;3;${ACCENT_SKY}\033\\"
    osc+="\033]4;4;${ACCENT_LBLUE}\033\\"
    osc+="\033]4;5;${ACCENT_MAGENTA}\033\\"
    osc+="\033]4;6;${ACCENT_TEAL}\033\\"
    osc+="\033]4;7;${FG0}\033\\"
    osc+="\033]4;8;${BG2}\033\\"
    osc+="\033]4;9;${ACCENT_PINK}\033\\"
    osc+="\033]4;10;${ACCENT_GREEN}\033\\"
    osc+="\033]4;11;${ACCENT_SKY}\033\\"
    osc+="\033]4;12;${ACCENT_LBLUE}\033\\"
    osc+="\033]4;13;${ACCENT_MAGENTA}\033\\"
    osc+="\033]4;14;${ACCENT_TEAL}\033\\"
    osc+="\033]4;15;#ffffff\033\\"

    # Ghostty holds pty masters as /dev/ptmx (kernel doesn't label them by
    # slave number). The slave path lives on the child shell's fd 0. Walk
    # ghostty's descendants, collect unique /dev/pts/N, write OSC to each.
    local uid gpid cpid tgt
    uid=$(id -u)
    declare -A seen=()
    for gpid in $(pgrep -u "$uid" -x ghostty 2>/dev/null); do
      while read -r cpid; do
        [[ -z "$cpid" ]] && continue
        tgt=$(readlink "/proc/$cpid/fd/0" 2>/dev/null) || continue
        [[ "$tgt" == /dev/pts/* ]] || continue
        [[ -n "${seen[$tgt]:-}" ]] && continue
        seen[$tgt]=1
        printf '%b' "$osc" >"$tgt" 2>/dev/null || true
      done < <(pgrep -P "$gpid" 2>/dev/null)
    done
  }
  ghostty_live_update
  pkill -SIGUSR2 ghostty 2>/dev/null || true

  # Kitty: live color reload
  if command -v kitty &>/dev/null && pgrep -x kitty &>/dev/null; then
    kitty @ set-colors --all --configured \
      "$HOME/.config/kitty/themes/noctalia.conf" 2>/dev/null || true
  fi

  # Alacritty: touch config to trigger live reload
  if pgrep -x alacritty &>/dev/null; then
    touch "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || true
  fi

  # Mako: reload notification daemon
  makoctl reload 2>/dev/null || true

  # Tmux: source config if server is running
  if tmux list-sessions &>/dev/null; then
    tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true
  fi

  # Notification
  notify-send -t 3000 "Theme Switcher" "Applied: $THEME_NAME" \
    -i preferences-desktop-theme 2>/dev/null || true
}

# ── Set wallpaper ───────────────────────────────────────────────────
set_wallpaper() {
  local transition=${TRANSITIONS[$((RANDOM % ${#TRANSITIONS[@]}))]}
  awww img "$1" \
    --transition-type "$transition" \
    --transition-duration 2 \
    --transition-fps 60 \
    --transition-step 90
}

# ── Main ────────────────────────────────────────────────────────────
main() {
  local entries=""

  # Oxocarbon default thumbnail — use current wallpaper if awww is running
  local oxo_thumb="$THUMB_DIR/oxocarbon-default.png"
  local current_wall
  current_wall=$(awww query 2>/dev/null | awk -F'image: ' '/image: /{print $2; exit}')
  if [[ -n "$current_wall" && -f "$current_wall" && (! -f "$oxo_thumb" || "$current_wall" -nt "$oxo_thumb") ]]; then
    magick "$current_wall" -resize 256x144^ -gravity center -extent 256x144 "$oxo_thumb" 2>/dev/null
  elif [[ ! -f "$oxo_thumb" ]]; then
    magick -size 256x144 "xc:${oxo_BG0}" \
      -fill "${oxo_LBLUE}" -pointsize 28 \
      -gravity center -annotate +0-10 'Oxocarbon' \
      -fill "${oxo_TEAL}" -pointsize 14 \
      -gravity center -annotate +0+20 'Default Theme' \
      "$oxo_thumb" 2>/dev/null ||
      magick -size 256x144 "xc:${oxo_BG0}" "$oxo_thumb"
  fi
  entries+="Oxocarbon (Default)\0icon\x1f${oxo_thumb}\n"

  # Wallpaper entries
  while IFS= read -r file; do
    local name thumb
    name=$(basename "$file")
    thumb="$THUMB_DIR/$name"

    # Generate thumbnail (still cached — image data doesn't change)
    if [[ ! -f "$thumb" || "$file" -nt "$thumb" ]]; then
      magick "$file" -resize 256x144^ -gravity center -extent 256x144 "$thumb" 2>/dev/null
    fi

    entries+="${name}\0icon\x1f${thumb}\n"
  done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
    -o -iname '*.webp' -o -iname '*.gif' \) | sort)

  # Launch rofi
  local selection
  selection=$(printf '%b' "$entries" | rofi -dmenu \
    -p " Theme" \
    -theme "$STYLE" \
    -show-icons \
    -kb-move-char-back "" \
    -kb-move-char-forward "" \
    -kb-row-up "Alt+k,Up" \
    -kb-row-down "Alt+j,Down" \
    -kb-row-left "Alt+h,Left" \
    -kb-row-right "Alt+l,Right" \
    -kb-clear-line "Alt+c,slash") || true

  [[ -z "$selection" ]] && exit 0

  # Parse selection
  THEME_NAME="$selection"

  if [[ "$selection" == "Oxocarbon (Default)" ]]; then
    load_oxocarbon
  else
    extract_palette "$WALLPAPER_DIR/$selection"
    set_wallpaper "$WALLPAPER_DIR/$selection"
  fi

  generate_all
  reload_all
}

main "$@"

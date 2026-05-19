#!/usr/bin/env bash
#
# Keybind cheatsheet via rofi — appears only on the focused monitor.
# Parses niri config.kdl with zero subprocesses in the hot loop.
#

CONFIG="$HOME/.config/niri/config.kdl"
STYLE="$HOME/.config/rofi/keybinds.rasi"

# Colors for markup — sourced from theme-switcher cache, fallback to Oxocarbon
THEME_COLOR_KEY="#78a9ff"
THEME_COLOR_DESC="#dde1e6"
THEME_COLOR_HEADER="#08bdba"
# shellcheck source=/dev/null
[[ -f "$HOME/.cache/theme-switcher/colors.sh" ]] && source "$HOME/.cache/theme-switcher/colors.sh"
C_KEY="<span foreground='${THEME_COLOR_KEY}'>"
C_DESC="<span foreground='${THEME_COLOR_DESC}'>"
C_END="</span>"
KEY_WIDTH=18

declare -a entries
declare -A seen_actions
in_binds=false
brace_depth=0
pending_header=""
_entry=""

flush_header() {
    if [[ -n "$pending_header" ]]; then
        entries+=("<span foreground='${THEME_COLOR_HEADER}'>── ${pending_header} ──</span>")
        pending_header=""
    fi
}

# Title-case a hyphenated string; result in $_entry (no subshell)
title_case() {
    local input="${1//-/ }" word
    _entry=""
    for word in $input; do
        _entry+="${word^} "
    done
    _entry="${_entry% }"
}

add_entry() {
    local keys="$1" desc="$2"
    printf -v _entry "%-${KEY_WIDTH}s" "$desc"
    _entry="${C_DESC}${_entry}${C_END}  ${C_KEY}${keys}${C_END}"
    entries+=("$_entry")
}

while IFS= read -r line; do
    if [[ "$line" =~ ^binds[[:space:]]*\{ ]]; then
        in_binds=true; brace_depth=1; continue
    fi
    $in_binds || continue

    tmp="${line//[^\{]}"; opens=${#tmp}
    tmp="${line//[^\}]}"; closes=${#tmp}
    brace_depth=$(( brace_depth + opens - closes ))
    [[ $brace_depth -le 0 ]] && { in_binds=false; continue; }

    stripped="${line#"${line%%[! ]*}"}"

    # Section headers
    if [[ "$stripped" == //* ]]; then
        if [[ "$stripped" =~ //[[:space:]]*[─=]+[[:space:]]+(.+)[[:space:]]+[─=]+ ]]; then
            pending_header="${BASH_REMATCH[1]}"
        fi
        continue
    fi

    # Labelled binds (hotkey-overlay-title)
    if [[ "$line" == *'hotkey-overlay-title='* ]]; then
        keys="${line%%hotkey-overlay-title=*}"
        keys="${keys#"${keys%%[! ]*}"}"; keys="${keys%"${keys##*[! ]}"}"
        tmp="${line#*hotkey-overlay-title=\"}"; title="${tmp%%\"*}"
        if [[ -z "${seen_actions[$title]}" ]]; then
            seen_actions["$title"]=1
            flush_header
            add_entry "$keys" "$title"
        fi
        continue
    fi

    # Standard action binds
    if [[ "$stripped" =~ ^(Mod|MOD|CTRL)[^\ ]*\ .*\{\ *[a-z] ]]; then
        [[ "$stripped" == *WheelScroll* ]] && continue

        keys="${stripped%%\{*}"
        keys="${keys//repeat=false/}"; keys="${keys//allow-inhibiting=false/}"
        keys="${keys//allow-when-locked=true/}"
        keys="${keys#"${keys%%[! ]*}"}"; keys="${keys%"${keys##*[! ]}"}"

        tmp="${stripped#*\{}"; tmp="${tmp#"${tmp%%[! ]*}"}"
        action="${tmp%% *}"; action="${action%%;*}"

        [[ "$action" == "spawn" || "$action" == "spawn-sh" ]] && continue

        # Capture first arg if any (set-column-width "+10%", focus-workspace 3, etc.)
        rest="${tmp#"$action"}"
        rest="${rest#"${rest%%[! ]*}"}"
        arg="${rest%%;*}"
        arg="${arg%"${arg##*[! ]}"}"

        dedup_key="${action}${arg:+:$arg}"
        if [[ -z "${seen_actions[$dedup_key]}" ]]; then
            seen_actions["$dedup_key"]=1
            flush_header
            title_case "$action"
            add_entry "$keys" "${_entry}${arg:+ $arg}"
        fi
    fi
done < "$CONFIG"

total=${#entries[@]}
lines=$(( (total + 1) / 2 ))

printf '%s\n' "${entries[@]}" | rofi \
    -dmenu \
    -i \
    -p "Search" \
    -mesg "Keybinds" \
    -theme "$STYLE" \
    -monitor focused \
    -no-custom \
    -markup-rows \
    -lines "$lines" \
    -kb-move-char-back    "" \
    -kb-move-char-forward ""

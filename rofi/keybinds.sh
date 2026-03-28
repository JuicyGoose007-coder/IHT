#!/usr/bin/env bash
#
# Keybind cheatsheet via rofi — appears only on the focused monitor.
# Parses niri config.kdl with zero subprocesses in the hot loop.
#

CONFIG="$HOME/.config/niri/config.kdl"
STYLE="$HOME/.config/rofi/keybinds.rasi"

# Colors for markup
C_KEY="<span foreground='#78a9ff'>"
C_DESC="<span foreground='#dde1e6'>"
C_END="</span>"
KEY_WIDTH=22  # max real key length is 20 (Mod+Shift+Ctrl+Right)

declare -a entries
declare -A seen_actions
in_binds=false
brace_depth=0
pending_header=""
_entry=""

flush_header() {
    [[ -n "$pending_header" ]] && \
        entries+=("<span foreground='#08bdba'>── ${pending_header} ──</span>") && \
        pending_header=""
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
    printf -v _entry "%-${KEY_WIDTH}s" "$keys"
    _entry="${C_KEY}${_entry}${C_END}  ${C_DESC}${desc}${C_END}"
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
        [[ "$stripped" =~ ^Mod\+[0-9][[:space:]] ]] && continue
        [[ "$stripped" =~ ^Mod\+Shift\+[0-9][[:space:]] ]] && continue

        keys="${stripped%%\{*}"
        keys="${keys//repeat=false/}"; keys="${keys//allow-inhibiting=false/}"
        keys="${keys//allow-when-locked=true/}"
        keys="${keys#"${keys%%[! ]*}"}"; keys="${keys%"${keys##*[! ]}"}"

        tmp="${stripped#*\{}"; tmp="${tmp#"${tmp%%[! ]*}"}"
        action="${tmp%% *}"; action="${action%%;*}"
        [[ "$action" == "spawn" || "$action" == "spawn-sh" ]] && continue

        if [[ -z "${seen_actions[$action]}" ]]; then
            seen_actions["$action"]=1
            flush_header
            title_case "$action"
            add_entry "$keys" "$_entry"
        fi
    fi
done < "$CONFIG"

total=${#entries[@]}
lines=$(( (total + 1) / 2 ))

printf '%s\n' "${entries[@]}" | rofi \
    -dmenu \
    -p "" \
    -mesg "Keybinds" \
    -theme "$STYLE" \
    -monitor focused \
    -no-custom \
    -markup-rows \
    -lines "$lines" \
    -kb-move-char-back    "" \
    -kb-move-char-forward "" \
    -kb-row-up   "Alt+k,Up" \
    -kb-row-down "Alt+j,Down"

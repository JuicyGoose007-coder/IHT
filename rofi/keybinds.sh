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
declare -a header_positions
declare -A seen_actions
in_binds=false
brace_depth=0
pending_header=""
_entry=""

flush_header() {
    if [[ -n "$pending_header" ]]; then
        header_positions+=("${#entries[@]}")
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

        keys="${stripped%%\{*}"
        keys="${keys//repeat=false/}"; keys="${keys//allow-inhibiting=false/}"
        keys="${keys//allow-when-locked=true/}"
        keys="${keys#"${keys%%[! ]*}"}"; keys="${keys%"${keys##*[! ]}"}"

        tmp="${stripped#*\{}"; tmp="${tmp#"${tmp%%[! ]*}"}"
        action="${tmp%% *}"; action="${action%%;*}"

        if [[ "$action" == "spawn" || "$action" == "spawn-sh" ]]; then
            if [[ "$stripped" == *"toggle-overview"* ]]; then
                label="Toggle Overview"
            else
                spawn_arg="${stripped#*\"}"
                spawn_arg="${spawn_arg%%\"*}"
                label="${spawn_arg##*/}"
                label="${label%.sh}"
                title_case "$label"
                label="$_entry"
            fi
            if [[ -z "${seen_actions[$label]}" ]]; then
                seen_actions["$label"]=1
                flush_header
                add_entry "$keys" "$label"
            fi
            continue
        fi

        # Workspace actions: include arg in dedup key and description
        if [[ "$action" == "focus-workspace" || "$action" == "move-column-to-workspace" ]]; then
            ws_arg="${tmp#* }"; ws_arg="${ws_arg%%;*}"; ws_arg="${ws_arg%% }"
            dedup_key="${action}:${ws_arg}"
            if [[ -z "${seen_actions[$dedup_key]}" ]]; then
                seen_actions["$dedup_key"]=1
                flush_header
                title_case "$action"
                add_entry "$keys" "$_entry $ws_arg"
            fi
            continue
        fi

        if [[ -z "${seen_actions[$action]}" ]]; then
            seen_actions["$action"]=1
            flush_header
            title_case "$action"
            add_entry "$keys" "$_entry"
        fi
    fi
done < "$CONFIG"

total=${#entries[@]}

# Find section boundary that minimises padding (balances column lengths)
best_split=0
best_diff=$total
for pos in "${header_positions[@]}"; do
    diff=$(( pos - (total - pos) ))
    (( diff < 0 )) && diff=$(( -diff ))
    if (( diff < best_diff )); then
        best_diff=$diff
        best_split=$pos
    fi
done
split_at=$best_split

col1=("${entries[@]:0:$split_at}")
col2=("${entries[@]:$split_at}")

# Pad shorter column with blanks so interleave produces a full rectangle
while (( ${#col1[@]} < ${#col2[@]} )); do col1+=(""); done
while (( ${#col2[@]} < ${#col1[@]} )); do col2+=(""); done

# Interleave: rofi fills left→right so col1[i],col2[i] land on same row
final=()
for (( i=0; i<${#col1[@]}; i++ )); do
    final+=("${col1[$i]}" "${col2[$i]}")
done

lines=${#col1[@]}

printf '%s\n' "${final[@]}" | rofi \
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

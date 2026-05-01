#!/bin/bash
# Parses niri config and outputs keybindings as a waybar JSON tooltip

CONFIG="$HOME/.config/niri/config.kdl"

tooltip=""
in_binds=false
brace_depth=0

while IFS= read -r line; do
    # Detect entering the binds block
    if [[ "$line" =~ ^binds[[:space:]]*\{ ]]; then
        in_binds=true
        brace_depth=1
        continue
    fi

    $in_binds || continue

    # Track brace depth to know when we exit the binds block
    opens=$(echo "$line" | grep -o '{' | wc -l)
    closes=$(echo "$line" | grep -o '}' | wc -l)
    brace_depth=$((brace_depth + opens - closes))
    if [[ $brace_depth -le 0 ]]; then
        in_binds=false
        continue
    fi

    # Skip commented-out binds
    echo "$line" | grep -qP '^\s*//' || true
    stripped=$(echo "$line" | sed 's/^[[:space:]]*//')
    [[ "$stripped" == //* ]] && {
        # But still detect section headers in comments
        if echo "$line" | grep -qP '^\s*//\s*[─]+\s+(.+?)\s+[─]+'; then
            header=$(echo "$line" | sed -E 's|^\s*//\s*[─]+\s+||; s|\s*[─]+\s*$||')
            [[ -n "$tooltip" ]] && tooltip="${tooltip}\n"
            tooltip="${tooltip}<b>${header}</b>\n"
        elif echo "$line" | grep -qP '^\s*//\s*===+\s+(.+?)\s+==='; then
            header=$(echo "$line" | sed -E 's|^\s*//\s*=+\s+||; s|\s*=+\s*$||')
            [[ -n "$tooltip" ]] && tooltip="${tooltip}\n"
            tooltip="${tooltip}<b>${header}</b>\n"
        fi
        continue
    }

    # Match lines with hotkey-overlay-title
    if echo "$line" | grep -qP 'hotkey-overlay-title='; then
        keys=$(echo "$line" | sed -E 's/^\s+//; s/\s*hotkey-overlay-title=.*//' | xargs)
        title=$(echo "$line" | grep -oP 'hotkey-overlay-title="\K[^"]+')
        tooltip="${tooltip}  ${keys}  →  ${title}\n"
        continue
    fi

    # Match simple keybinds: Mod+Key { action; }
    if echo "$line" | grep -qP '^\s*(Mod|MOD|CTRL)\S*\s.*\{\s*[a-z]'; then
        # Skip mouse wheel and numbered workspace binds
        echo "$line" | grep -qP 'WheelScroll' && continue
        echo "$line" | grep -qP '^\s*Mod\+[0-9]\s' && continue
        echo "$line" | grep -qP '^\s*Mod\+Shift\+[0-9]\s' && continue
        # Skip XF86 media keys
        echo "$line" | grep -qP '^\s*XF86' && continue

        keys=$(echo "$line" | sed -E 's/^\s+//; s/\s*\{.*//' | sed 's/repeat=false//; s/allow-inhibiting=false//; s/allow-when-locked=true//' | xargs)
        action=$(echo "$line" | grep -oP '\{\s*\K[a-z-]+')
        # Skip spawn actions without overlay title (already handled above)
        [[ "$action" == "spawn" || "$action" == "spawn-sh" ]] && continue
        # Format action: close-window -> Close Window
        action=$(echo "$action" | sed 's/-/ /g; s/\b./\u&/g')
        tooltip="${tooltip}  ${keys}  →  ${action}\n"
    fi

done < "$CONFIG"

# Add numbered workspace note
tooltip="${tooltip}\n<b>Workspaces</b>\n  Mod+[1-9]  →  Focus Workspace N\n  Mod+Shift+[1-9]  →  Move to Workspace N"

# Output as waybar JSON
printf '{"text": "⌨", "tooltip": "%s"}' "$tooltip"

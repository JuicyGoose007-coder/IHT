#!/usr/bin/env bash
#
# Keybind cheatsheet via rofi — appears only on the focused monitor.
# Parses Hyprland modules/keybinds.lua with zero subprocesses in the hot loop.
#

CONFIG="$HOME/.config/hypr/modules/keybinds.lua"
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
in_bind=false
buffer=""
pending_header=""
section_has_content=false

flush_header() {
	if [[ -n "$pending_header" ]]; then
		entries+=("<span foreground='${THEME_COLOR_HEADER}'>── ${pending_header} ──</span>")
		pending_header=""
		section_has_content=false
	fi
}

add_entry() {
	local keys="$1" desc="$2"
	local _entry
	flush_header
	printf -v _entry "%-${KEY_WIDTH}s" "$desc"
	_entry="${C_DESC}${_entry}${C_END}  ${C_KEY}${keys}${C_END}"
	entries+=("$_entry")
	section_has_content=true
}

# Strip Lua string literals so paren counting ignores parens in strings
strip_strings() {
	local text="$1"
	if command -v perl &>/dev/null; then
		perl -pe 's/\[=+\[.*?\]=+\]//g; s/'\''[^'\'']*'\''//g; s/"[^"]*"//g' <<< "$text" 2>/dev/null
	else
		sed "s/'[^']*'//g; s/\"[^\"]*\"//g" <<< "$text"
	fi
}

##############################
# Description derivation
##############################

derive_description() {
	local buffer="$1"

	# hl.dsp.window.*
	[[ "$buffer" == *"hl.dsp.window.close()"* ]] && { echo "Close Window"; return; }
	if [[ "$buffer" == *"hl.dsp.window.fullscreen"* ]]; then
		if [[ "$buffer" != *"fullscreen(0)"* ]]; then
			echo "Toggle Fullscreen"
		else
			echo "Fullscreen"
		fi
		return
	fi
	[[ "$buffer" == *"hl.dsp.window.float"* ]] && { echo "Toggle Float"; return; }
	[[ "$buffer" == *"hl.dsp.window.drag()"* ]] && { echo "Drag Window"; return; }
	[[ "$buffer" == *"hl.dsp.window.resize()"* ]] && { echo "Resize Window"; return; }

	if [[ "$buffer" == *"hl.dsp.window.move"* ]]; then
		local dir ws mon
		dir=$(grep -oP 'direction\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$dir" ]]; then echo "Move Window ${dir^}"; return; fi
		ws=$(grep -oP 'workspace\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$ws" ]]; then ws="${ws#name:}"; ws="${ws#special:}"; echo "Move to ${ws}"; return; fi
		mon=$(grep -oP 'monitor\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$mon" ]]; then
			case "$mon" in l) mon="Left" ;; r) mon="Right" ;; u) mon="Up" ;; d) mon="Down" ;; esac
			echo "Move to Monitor ${mon}"; return
		fi
		echo "Move Window"; return
	fi

	# hl.dsp.focus.*
	if [[ "$buffer" == *"hl.dsp.focus"* ]]; then
		[[ "$buffer" == *'{last=true}'* ]] || [[ "$buffer" == *'{last = true}'* ]] && { echo "Focus Last Window"; return; }
		local dir ws
		dir=$(grep -oP 'direction\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$dir" ]]; then echo "Focus ${dir^}"; return; fi
		ws=$(grep -oP 'workspace\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$ws" ]]; then
			ws="${ws#name:}"
			if [[ "$ws" == "e+1" ]]; then echo "Next Workspace"; return
			elif [[ "$ws" == "e-1" ]]; then echo "Previous Workspace"; return
			fi
			echo "Focus ${ws}"; return
		fi
		ws=$(grep -oP 'workspace\s*=\s*(\w+)' <<< "$buffer" | head -1 | sed 's/.*=\s*\(.*\)/\1/')
		[[ -n "$ws" ]] && { echo "Focus Workspace ${ws}"; return; }
		echo "Focus"; return
	fi

	# hl.dsp.layout(...)
	if [[ "$buffer" == *"hl.dsp.layout"* ]]; then
		local arg
		arg=$(grep -oP 'layout\(\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)"/\1/')
		[[ -z "$arg" ]] && arg=$(grep -oP "layout\(\s*'([^']+)'" <<< "$buffer" | head -1 | sed "s/.*'\(.*\)'/\1/")
		if [[ -n "$arg" ]]; then
			case "$arg" in
				consume_or_expel\ prev) echo "Consume Window (Prev)" ;;
				consume_or_expel\ next) echo "Expel Window (Next)" ;;
				promote) echo "Promote Window" ;;
				togglegroup) echo "Toggle Group" ;;
				colresize\ +conf) echo "Column Resize +" ;;
				colresize\ -conf) echo "Column Resize -" ;;
				colresize\ +0.1) echo "Column Size +" ;;
				colresize\ -0.1) echo "Column Size -" ;;
				colresize\ +0.05) echo "Column Size +" ;;
				colresize\ -0.05) echo "Column Size -" ;;
				fit\ active) echo "Fit Active" ;;
				fit\ visible) echo "Fit Visible" ;;
				focus\ r) echo "Focus Right Column" ;;
				focus\ l) echo "Focus Left Column" ;;
				move\ +col) echo "Move to Right Column" ;;
				move\ -col) echo "Move to Left Column" ;;
				*)
					local word result=""
					for word in $arg; do result+="${word^} "; done
					echo "${result% }" ;;
			esac
			return
		fi
		echo "Layout Action"; return
	fi

	# hl.dsp.workspace.toggle_special
	if [[ "$buffer" == *"hl.dsp.workspace.toggle_special"* ]]; then
		local spec
		spec=$(grep -oP 'toggle_special\(\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)"/\1/')
		if [[ -n "$spec" ]]; then echo "Toggle ${spec^}"; else echo "Toggle Scratchpad"; fi
		return
	fi

	# hl.plugin.hymission.*
	if [[ "$buffer" == *"hl.plugin.hymission"* ]]; then
		[[ "$buffer" == *"hl.plugin.hymission.close"* ]] && { echo "Close Overview"; return; }
		[[ "$buffer" == *"forceall"* ]] && { echo "Overview (All Workspaces)"; return; }
		[[ "$buffer" == *"onlycurrentworkspace"* ]] && { echo "Overview (Current WS)"; return; }
		[[ "$buffer" == *"hl.plugin.hymission.toggle"* ]] && { echo "Overview Toggle"; return; }
		[[ "$buffer" == *"hl.plugin.hymission"* ]] && { echo "Open Overview"; return; }
		echo "Hymission"; return
	fi

	# hl.dsp.exit
	[[ "$buffer" == *"hl.dsp.exit()"* ]] && { echo "Exit Hyprland"; return; }

	# hl.dsp.exec_cmd
	if [[ "$buffer" == *"hl.dsp.exec_cmd"* ]]; then
		local cmd_str=""
		if [[ "$buffer" =~ exec_cmd\([[:space:]]*\"([^\"]+)\" ]]; then
			cmd_str="${BASH_REMATCH[1]}"
		elif [[ "$buffer" =~ exec_cmd\([[:space:]]*\'([^\']+)\' ]]; then
			cmd_str="${BASH_REMATCH[1]}"
		elif [[ "$buffer" =~ exec_cmd\([[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\) ]]; then
			# Bare variable reference
			local var_name="${BASH_REMATCH[1]}"
			case "$var_name" in
				terminal) cmd_str="terminal" ;;
				fileManager) cmd_str="fileManager" ;;
				menu) cmd_str="menu" ;;
			esac
		fi
		# Fallback: check full buffer for known patterns (e.g., long bracket strings)
		if [[ -z "$cmd_str" ]]; then
			if [[ "$buffer" == *"activewindow"* ]]; then
				cmd_str="grim activewindow"
			fi
		fi
		if [[ -n "$cmd_str" ]]; then
			case "$cmd_str" in
				*terminal*) echo "Open Terminal"; return ;;
				*fileManager*) echo "File Manager"; return ;;
				*firefox*) echo "Firefox"; return ;;
				*brave*) echo "Brave"; return ;;
				*launcher*) echo "App Launcher"; return ;;
				*wallpaper-switcher*) echo "Wallpaper Switcher"; return ;;
				*theme-switcher*) echo "Theme Switcher"; return ;;
				*waybar-layout-switcher*) echo "Layout Switcher"; return ;;
				*keybinds*) echo "Keybind Cheatsheet"; return ;;
				*swaync*) echo "Toggle Notifications"; return ;;
				*hyprlock*) echo "Lock Screen"; return ;;
				*yazi*) echo "File Explorer (Yazi)"; return ;;
				*cliphist*) echo "Clipboard History"; return ;;
				*wpctl*set-volume*5%\+*) echo "Volume Up"; return ;;
				*wpctl*set-volume*5%-*) echo "Volume Down"; return ;;
			*wpctl*set-mute*SOURCE*) echo "Toggle Mic Mute"; return ;;
			*wpctl*set-mute*toggle*) echo "Toggle Mute"; return ;;
				*brightnessctl*5%\+*) echo "Brightness Up"; return ;;
				*brightnessctl*5%-*) echo "Brightness Down"; return ;;
				*playerctl*next*) echo "Next Track"; return ;;
				*playerctl*previous*) echo "Previous Track"; return ;;
				*playerctl*play-pause*) echo "Play/Pause"; return ;;
			*grim*slurp*) echo "Screenshot (Area)"; return ;;
			*grim*activewindow*|*\[=*activewindow*) echo "Screenshot (Window)"; return ;;
			*grim*) echo "Screenshot (Monitor)"; return ;;
				*dpms\ off*) echo "DPMS Off"; return ;;
			esac
		fi
		echo "Launch Command"; return
	fi

	# function() — custom keybinds
	if [[ "$buffer" == *"function()"* ]]; then
		[[ "$buffer" == *"opacity"* ]] && { echo "Toggle Opacity"; return; }
		[[ "$buffer" == *"layout"* ]] && { echo "Cycle Layout"; return; }
		echo "Custom Action"; return
	fi

	echo "Action"
}

##############################
# Bind processing
##############################

process_bind() {
	local buf="$1"

	# Extract keys from first quoted string after hl.bind(
	local keys=""
	if [[ "$buf" =~ hl\.bind\([[:space:]]*\"([^\"]+)\" ]]; then
		keys="${BASH_REMATCH[1]}"
	elif [[ "$buf" =~ hl\.bind\([[:space:]]*\'([^\']+)\' ]]; then
		keys="${BASH_REMATCH[1]}"
	fi
	[[ -z "$keys" ]] && return

	# Skip dynamic binds from for-loops (string concatenation in key)
	local after_match="${buf#*\"$keys\"}"
	after_match="${after_match#"${after_match%%[! ]*}"}"
	[[ "$after_match" == \.\.* ]] && return
	after_match="${buf#*\'$keys\'}"
	after_match="${after_match#"${after_match%%[! ]*}"}"
	[[ "$after_match" == \.\.* ]] && return

	local desc
	desc=$(derive_description "$buf")
	add_entry "$keys" "$desc"
}

##############################
# Main parsing loop
##############################

while IFS= read -r line; do
	stripped="${line#"${line%%[! ]*}"}"

	# Section headers from Lua comments
	if [[ "$stripped" == --* ]] && [[ "$in_bind" == false ]]; then
		header_text="${stripped#-- }"
		header_text="${header_text#"${header_text%%[! ]*}"}"
		header_text="${header_text%"${header_text##*[! ]}"}"
		if [[ -n "$header_text" ]]; then
			case "$header_text" in
				Example\ binds*|Opacity\ toggle*|Screenshots:*|Requires*|Swap\ window*|Toggle\ between*|Move/resize*) ;;
				*-----*) ;;
				*=*) ;;
				*) pending_header="$header_text" ;;
			esac
		fi
		continue
	fi

	# Start of a bind
	if [[ "$stripped" =~ ^hl\.bind\( ]]; then
		[[ "$in_bind" == true ]] && { in_bind=false; buffer=""; }
		in_bind=true
		buffer="$line"
	elif [[ "$in_bind" == true ]]; then
		buffer="$buffer"$'\n'"$line"
	else
		continue
	fi

	# Check if bind is complete (parens balanced, ignoring strings)
	clean=$(strip_strings "$buffer")
	opens="${clean//[^\(]/}"
	closes="${clean//[^\)]/}"
	if [[ "${#opens}" -gt 0 ]] && [[ "${#opens}" -eq "${#closes}" ]]; then
		process_bind "$buffer"
		in_bind=false
		buffer=""
	fi

done < "$CONFIG"

# Append workspace summary
pending_header="Workspaces"
add_entry "SUPER + N,2-9" "Focus Workspace"
add_entry "SUPER + SHIFT + N,2-9" "Move to Workspace"

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

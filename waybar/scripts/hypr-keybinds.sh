#!/bin/bash
# Parses Hyprland keybinds.lua and outputs keybindings as a waybar JSON tooltip

CONFIG="$HOME/.config/hypr/modules/keybinds.lua"

tooltip=""
in_bind=false
buffer=""

strip_strings() {
	local text="$1"
	if command -v perl &>/dev/null; then
		perl -pe 's/\[=+\[.*?\]=+\]//g; s/'\''[^'\'']*'\''//g; s/"[^"]*"//g' <<< "$text" 2>/dev/null
	else
		sed "s/'[^']*'//g; s/\"[^\"]*\"//g" <<< "$text"
	fi
}

derive_label() {
	local buffer="$1"

	[[ "$buffer" == *"hl.dsp.window.close()"* ]] && { echo "Close Window"; return; }
	if [[ "$buffer" == *"hl.dsp.window.fullscreen"* ]]; then
		[[ "$buffer" != *"fullscreen(0)"* ]] && echo "Toggle Fullscreen" || echo "Fullscreen"
		return
	fi
	[[ "$buffer" == *"hl.dsp.window.float"* ]] && { echo "Toggle Float"; return; }
	[[ "$buffer" == *"hl.dsp.window.drag()"* ]] && { echo "Drag Window"; return; }
	[[ "$buffer" == *"hl.dsp.window.resize()"* ]] && { echo "Resize Window"; return; }

	if [[ "$buffer" == *"hl.dsp.window.move"* ]]; then
		local dir ws mon
		dir=$(grep -oP 'direction\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		[[ -n "$dir" ]] && { echo "Move Window ${dir^}"; return; }
		ws=$(grep -oP 'workspace\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		[[ -n "$ws" ]] && { ws="${ws#name:}"; ws="${ws#special:}"; echo "Move to ${ws}"; return; }
		mon=$(grep -oP 'monitor\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$mon" ]]; then
			case "$mon" in l) mon="Left" ;; r) mon="Right" ;; u) mon="Up" ;; d) mon="Down" ;; esac
			echo "Move to Monitor ${mon}"; return
		fi
		echo "Move Window"; return
	fi

	if [[ "$buffer" == *"hl.dsp.focus"* ]]; then
		[[ "$buffer" == *'{last=true}'* ]] || [[ "$buffer" == *'{last = true}'* ]] && { echo "Focus Last Window"; return; }
		local dir ws
		dir=$(grep -oP 'direction\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		[[ -n "$dir" ]] && { echo "Focus ${dir^}"; return; }
		ws=$(grep -oP 'workspace\s*=\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)".*/\1/')
		if [[ -n "$ws" ]]; then
			ws="${ws#name:}"
			if [[ "$ws" == "e+1" ]]; then echo "Next Workspace"; return
			elif [[ "$ws" == "e-1" ]]; then echo "Prev Workspace"; return
			fi
			echo "Focus ${ws}"; return
		fi
		ws=$(grep -oP 'workspace\s*=\s*(\w+)' <<< "$buffer" | head -1 | sed 's/.*=\s*\(.*\)/\1/')
		[[ -n "$ws" ]] && { echo "Focus Workspace ${ws}"; return; }
		echo "Focus"; return
	fi

	if [[ "$buffer" == *"hl.dsp.layout"* ]]; then
		local arg
		arg=$(grep -oP 'layout\(\s*"([^"]+)"' <<< "$buffer" | head -1 | sed 's/.*"\(.*\)"/\1/')
		if [[ -n "$arg" ]]; then
			case "$arg" in
				consume_or_expel\ prev) echo "Consume Prev" ;; consume_or_expel\ next) echo "Expel Next" ;;
				promote) echo "Promote" ;; togglegroup) echo "Toggle Group" ;;
				colresize\ +conf) echo "Col Resize +" ;; colresize\ -conf) echo "Col Resize -" ;;
				colresize\ +0.1) echo "Col Size +" ;; colresize\ -0.1) echo "Col Size -" ;;
				colresize\ +0.05) echo "Col Size +" ;; colresize\ -0.05) echo "Col Size -" ;;
				fit\ active) echo "Fit Active" ;; fit\ visible) echo "Fit Visible" ;;
				focus\ r) echo "Focus Right Col" ;; focus\ l) echo "Focus Left Col" ;;
				move\ +col) echo "Move Right Col" ;; move\ -col) echo "Move Left Col" ;;
				*) echo "${arg^}" ;;
			esac
			return
		fi
		echo "Layout"; return
	fi

	[[ "$buffer" == *"hl.dsp.workspace.toggle_special"* ]] && { echo "Toggle Scratchpad"; return; }

	if [[ "$buffer" == *"hl.plugin.hymission"* ]]; then
		[[ "$buffer" == *"close"* ]] && { echo "Close Overview"; return; }
		[[ "$buffer" == *"forceall"* ]] && { echo "Overview All"; return; }
		[[ "$buffer" == *"onlycurrentworkspace"* ]] && { echo "Overview Current"; return; }
		echo "Overview"; return
	fi

	[[ "$buffer" == *"hl.dsp.exit()"* ]] && { echo "Exit Hyprland"; return; }

	if [[ "$buffer" == *"hl.dsp.exec_cmd"* ]]; then
		local cmd_str=""
		[[ "$buffer" =~ exec_cmd\([[:space:]]*\"([^\"]+)\" ]] && cmd_str="${BASH_REMATCH[1]}"
		[[ -z "$cmd_str" && "$buffer" =~ exec_cmd\([[:space:]]*\'([^\']+)\' ]] && cmd_str="${BASH_REMATCH[1]}"
		# Bare variable reference
		[[ -z "$cmd_str" && "$buffer" =~ exec_cmd\([[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\) ]] && cmd_str="${BASH_REMATCH[1]}"

		# Fallback: check full buffer for patterns in long bracket strings
		[[ -z "$cmd_str" && "$buffer" == *"activewindow"* ]] && cmd_str="grim activewindow"

		if [[ -n "$cmd_str" ]]; then
			case "$cmd_str" in
				*terminal*) echo "Terminal" ;; *fileManager*) echo "File Manager" ;;
				*firefox*) echo "Firefox" ;; *brave*) echo "Brave" ;;
				*launcher*) echo "Launcher" ;; *wallpaper-switcher*) echo "Wallpaper" ;;
				*theme-switcher*) echo "Theme" ;; *waybar-layout-switcher*) echo "Layout Switcher" ;;
				*keybinds*) echo "Keybinds" ;; *swaync*) echo "Notifications" ;;
				*hyprlock*) echo "Lock" ;; *yazi*) echo "Yazi" ;;
				*cliphist*) echo "Clipboard" ;;
				*wpctl*set-volume*5%\+*) echo "Vol Up" ;; *wpctl*set-volume*5%-*) echo "Vol Down" ;;
				*wpctl*set-mute*SOURCE*) echo "Mic Mute" ;; *wpctl*set-mute*toggle*) echo "Mute" ;;
				*brightnessctl*5%\+*) echo "Bright Up" ;; *brightnessctl*5%-*) echo "Bright Down" ;;
				*playerctl*next*) echo "Next Track" ;; *playerctl*previous*) echo "Prev Track" ;;
				*playerctl*play-pause*) echo "Play/Pause" ;;
				*grim*slurp*) echo "Screenshot Area" ;; *grim*activewindow*|*\[=*activewindow*) echo "Screenshot Win" ;;
				*grim*) echo "Screenshot" ;; *dpms\ off*) echo "DPMS Off" ;;
				*) echo "Run $(basename "$cmd_str" | sed 's/\.sh//')" ;;
			esac
			return
		fi
		echo "Run"; return
	fi

	if [[ "$buffer" == *"function()"* ]]; then
		[[ "$buffer" == *"opacity"* ]] && { echo "Opacity Toggle"; return; }
		[[ "$buffer" == *"layout"* ]] && { echo "Cycle Layout"; return; }
		echo "Custom"; return
	fi

	echo "Action"
}

while IFS= read -r line; do
	stripped="${line#"${line%%[! ]*}"}"

	# Section headers
	if [[ "$stripped" == --* ]] && [[ "$in_bind" == false ]]; then
		header_text="${stripped#-- }"
		header_text="${header_text#"${header_text%%[! ]*}"}"
		header_text="${header_text%"${header_text##*[! ]}"}"
		if [[ -n "$header_text" ]]; then
			case "$header_text" in
				Example\ binds*|Opacity\ toggle*|Screenshots:*|Requires*|Swap\ window*|Toggle\ between*|Move/resize*) ;;
				*-----*) ;;
				*=*) ;;
				*)
					[[ -n "$tooltip" ]] && tooltip="${tooltip}\n"
					tooltip="${tooltip}<b>${header_text}</b>\n" ;;
			esac
		fi
		continue
	fi

	# Start bind
	if [[ "$stripped" =~ ^hl\.bind\( ]]; then
		[[ "$in_bind" == true ]] && { in_bind=false; buffer=""; }
		in_bind=true
		buffer="$line"
	elif [[ "$in_bind" == true ]]; then
		buffer="$buffer"$'\n'"$line"
	else
		continue
	fi

	# Check completeness
	clean=$(strip_strings "$buffer")
	opens="${clean//[^\(]/}"
	closes="${clean//[^\)]/}"
	if [[ "${#opens}" -gt 0 ]] && [[ "${#opens}" -eq "${#closes}" ]]; then
		# Extract keys
		keys=""
		if [[ "$buffer" =~ hl\.bind\([[:space:]]*\"([^\"]+)\" ]]; then
			keys="${BASH_REMATCH[1]}"
		elif [[ "$buffer" =~ hl\.bind\([[:space:]]*\'([^\']+)\' ]]; then
			keys="${BASH_REMATCH[1]}"
		fi
		if [[ -n "$keys" ]]; then
			# Skip dynamic binds
			after_match="${buffer#*\"$keys\"}"
			after_match="${after_match#"${after_match%%[! ]*}"}"
			[[ "$after_match" == \.\.* ]] && { in_bind=false; buffer=""; continue; }
			after_match="${buffer#*\'$keys\'}"
			after_match="${after_match#"${after_match%%[! ]*}"}"
			[[ "$after_match" == \.\.* ]] && { in_bind=false; buffer=""; continue; }

			label=$(derive_label "$buffer")
			tooltip="${tooltip}  ${keys}  →  ${label}\n"
		fi
		in_bind=false
		buffer=""
	fi
done < "$CONFIG"

# Workspace summary
tooltip="${tooltip}\n<b>Workspaces</b>\n  SUPER + N,2-9  →  Focus Workspace\n  SUPER + SHIFT + N,2-9  →  Move to Workspace"

printf '{"text": "⌨", "tooltip": "%s"}' "$tooltip"

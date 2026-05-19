---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
local closeWindowBind = hl.bind("SUPER + Q", hl.dsp.window.close(), { repeating = false })

-- Opacity toggle (like Niri's MOD+T: toggle-window-rule-opacity)
local opacity_toggled = false
hl.bind("SUPER + T", function()
	opacity_toggled = not opacity_toggled
	hl.config({ decoration = { inactive_opacity = opacity_toggled and 1.0 or 0.9 } })
end)

-- Applications
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + D", hl.dsp.exec_cmd("~/.config/rofi/launcher.sh"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("brave"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("~/.config/rofi/wallpaper-switcher.sh"))
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("~/.config/rofi/theme-switcher-hyprland.sh"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd("ghostty -e zsh -ic yazi"))

-- Cliphist
hl.bind(
	"SUPER + ALT + V",
	hl.dsp.exec_cmd(
		"cliphist list | rofi -dmenu -theme ~/.config/rofi/cliphist.rasi -display-columns 2 | cliphist decode | wl-copy"
	)
)

-- Hymission overview
hl.bind("SUPER + TAB", hl.plugin.hymission.toggle)
hl.bind("SUPER + A", function()
	hl.plugin.hymission.toggle("forceall")
end)
hl.bind("SUPER + S", function()
	hl.plugin.hymission.open("onlycurrentworkspace")
end)
hl.bind("SUPER + Escape", hl.plugin.hymission.close)

-- Waybar layout switcher
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/rofi/waybar-layout-switcher.sh"))

-- Notification center
hl.bind("SUPER + V", hl.dsp.exec_cmd("swaync-client -t"))

-- Window Management
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + V", hl.dsp.focus({ last = true }))
hl.bind("SUPER + W", hl.dsp.layout("togglegroup"))

-- Sizing & Layout (scrolling layout equivalents)
hl.bind("SUPER + R", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen(0))
hl.bind("SUPER + C", hl.dsp.layout("fit active"))
hl.bind("SUPER + CTRL + C", hl.dsp.layout("fit visible"))

-- Manual column sizing
hl.bind("SUPER + Minus", hl.dsp.layout("colresize -0.1"))
hl.bind("SUPER + Equal", hl.dsp.layout("colresize +0.1"))

-- Swap window positions on current monitor (Niri-style with hjkl)
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Column management (Niri-style)
hl.bind("SUPER + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind("SUPER + bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind("SUPER + Period", hl.dsp.layout("promote"))

-- Column scroll navigation
hl.bind("SUPER + mouse_right", hl.dsp.layout("focus r"))
hl.bind("SUPER + mouse_left", hl.dsp.layout("focus l"))
hl.bind("SUPER + CTRL + mouse_right", hl.dsp.layout("move +col"))
hl.bind("SUPER + CTRL + mouse_left", hl.dsp.layout("move -col"))

-- Toggle between scrolling, dwindle, master
local layouts = { "scrolling", "dwindle", "master" }
local current_layout = 1
hl.bind("SUPER + U", function()
	current_layout = (current_layout % #layouts) + 1
	hl.config({ general = { layout = layouts[current_layout] } })
	os.execute("notify-send -t 2000 'Window Layout' '" .. layouts[current_layout] .. "' &")
end)

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))

-- Named workspaces
hl.bind("SUPER + G", hl.dsp.focus({ workspace = "name:Gaming" }))
hl.bind("SUPER + SHIFT + G", hl.dsp.window.move({ workspace = "name:Gaming" }))
hl.bind("SUPER + M", hl.dsp.focus({ workspace = "name:Main" }))
hl.bind("SUPER + SHIFT + M", hl.dsp.window.move({ workspace = "name:Main" }))
hl.bind("SUPER + I", hl.dsp.focus({ workspace = "name:Discord" }))
hl.bind("SUPER + SHIFT + I", hl.dsp.window.move({ workspace = "name:Discord" }))

-- Niri-style numbered workspaces: N=2, 4-9=4-9
local ws_keys = { "N", "2", "3", "4", "5", "6", "7", "8", "9" }
for i, key in ipairs(ws_keys) do
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind("SUPER + COMMA", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move window to adjacent monitor (Niri-style with hjkl)
hl.bind("SUPER + CTRL + h", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + CTRL + l", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + CTRL + k", hl.dsp.window.move({ monitor = "u" }))
hl.bind("SUPER + CTRL + j", hl.dsp.window.move({ monitor = "d" }))

-- System (Niri-style)
-- Screenshots: requires grim + slurp
hl.bind(
	"CTRL + S",
	hl.dsp.exec_cmd(
		'grim -g "$(slurp)" "$HOME/Pictures/screenshots/Screenshot from $(date \'+%Y-%m-%d %H-%M-%S\').png"'
	)
)
hl.bind(
	"CTRL + SHIFT + P",
	hl.dsp.exec_cmd(
		"grim -o \"$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')\" \"$HOME/Pictures/screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png\""
	)
)
hl.bind(
	"CTRL + SHIFT + W",
	hl.dsp.exec_cmd(
		[=[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$HOME/Pictures/screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"]=]
	)
)
hl.bind("CTRL + ALT + DELETE", hl.dsp.exit())
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.exec_cmd("~/.config/rofi/hypr-keybinds.sh"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

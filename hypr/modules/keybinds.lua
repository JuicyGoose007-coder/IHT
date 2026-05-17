---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { repeating = false })

-- Opacity toggle (like Niri's MOD+T: toggle-window-rule-opacity)
local opacity_toggled = false
hl.bind(mainMod .. " + T", function()
	opacity_toggled = not opacity_toggled
	hl.config({ decoration = { inactive_opacity = opacity_toggled and 1.0 or 0.9 } })
end)

-- Applications
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/rofi/launcher.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("~/.config/rofi/wallpaper-switcher.sh"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("~/.config/rofi/theme-switcher-hyprland.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("ghostty -e zsh -ic yazi"))

-- Notification center
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("swaync-client -t"))

-- Window Management
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("/mnt/storage/scripts/killgamescope.sh"), { repeating = false })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.focus({ last = true }))
hl.bind(mainMod .. " + W", hl.dsp.layout("togglegroup"))

-- Sizing & Layout (scrolling layout equivalents)
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen(0))
hl.bind(mainMod .. " + C", hl.dsp.layout("fit active"))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.layout("fit visible"))

-- Manual column sizing
hl.bind(mainMod .. " + Minus", hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + Equal", hl.dsp.layout("colresize +0.1"))

-- Swap window positions on current monitor (Niri-style with hjkl)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Column management (Niri-style)
hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + Period", hl.dsp.layout("promote"))

-- Column scroll navigation
hl.bind(mainMod .. " + mouse_right", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + mouse_left", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + CTRL + mouse_right", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + CTRL + mouse_left", hl.dsp.layout("move -col"))

-- Toggle between scrolling, dwindle, master
local layouts = { "scrolling", "dwindle", "master" }
local current_layout = 1
hl.bind(mainMod .. " + U", function()
	current_layout = (current_layout % #layouts) + 1
	hl.config({ general = { layout = layouts[current_layout] } })
	os.execute("notify-send -t 2000 'Window Layout' '" .. layouts[current_layout] .. "' &")
end)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Named workspaces
hl.bind(mainMod .. " + G", hl.dsp.focus({ workspace = "name:Gaming" }))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ workspace = "name:Gaming" }))
hl.bind(mainMod .. " + M", hl.dsp.focus({ workspace = "name:Main" }))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "name:Main" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = "name:Discord" }))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.window.move({ workspace = "name:Discord" }))

-- Niri-style numbered workspaces: M=2, N=3, 4-9=4-9
local ws_keys = { "N", "3", "4", "5", "6", "7", "8", "9" }
for i, key in ipairs(ws_keys) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move window to adjacent monitor (Niri-style with hjkl)
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ monitor = "r" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ monitor = "d" }))

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
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("~/.config/rofi/keybinds.sh"))

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

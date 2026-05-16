---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { repeating = false })

-- Applications
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/rofi/launcher.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("~/.config/rofi/wallpaper-switcher.sh"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("~/.config/rofi/theme-switcher.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("ghostty -e zsh -ic yazi"))

-- Window Management
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("/mnt/storage/scripts/killgamescope.sh"), { repeating = false })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.fullscreen(2))
hl.bind(mainMod .. " + F", hl.dsp.fullscreen())
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.focus({ floating = true }))
hl.bind(mainMod .. " + W", hl.dsp.layout("togglegroup"))

-- Sizing & Layout (scrolling layout equivalents)
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.fullscreen(0))
hl.bind(mainMod .. " + C", hl.dsp.layout("fit active"))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.layout("fit visible"))

-- Manual column sizing
hl.bind(mainMod .. " + Minus", hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + Equal", hl.dsp.layout("colresize +0.1"))

-- Column management (Niri-style)
hl.bind(mainMod .. " + bracket_left", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + bracket_right", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + Period", hl.dsp.layout("promote"))

-- Column scroll navigation
hl.bind(mainMod .. " + mouse_right", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + mouse_left", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + CTRL + mouse_right", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + CTRL + mouse_left", hl.dsp.layout("move -col"))

-- Toggle between scrolling, dwindle, master
hl.bind(mainMod .. " + T", hl.dsp.layout("cycle"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Niri-style numbered workspaces: G=1, M=2, N=3, 4-9=4-9
local ws_keys = { "G", "M", "N", "4", "5", "6", "7", "8", "9" }
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

-- System (Niri-style)
-- Screenshots: requires grim + slurp
hl.bind("CTRL + P", hl.dsp.exec_cmd("grim ~/Pictures/screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"))
hl.bind(
	"CTRL + SHIFT + P",
	hl.dsp.exec_cmd(
		"grim -o \"$(hyprctl monitors -j | gojq -r '.[] | select(.focused).name')\" ~/Pictures/screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
	)
)
hl.bind(
	"CTRL + SHIFT + W",
	hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png")
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

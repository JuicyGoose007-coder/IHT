------------------------
---- WINDOW RULES ----
------------------------

hl.window_rule({
	name = "firefox-pip",
	match = { class = "firefox", title = "^Picture-in-Picture$" },
	float = true,
})

hl.window_rule({
	name = "zoom",
	match = { class = "zoom" },
	float = true,
})

hl.window_rule({
	name = "float-gnome-calc",
	match = { class = "^gnome-calculator$" },
	float = true,
})

hl.window_rule({
	name = "float-galculator",
	match = { class = "^galculator$" },
	float = true,
})

hl.window_rule({
	name = "float-blueman",
	match = { class = "^blueman-manager$" },
	float = true,
})

hl.window_rule({
	name = "float-nautilus",
	match = { class = "^org\\.gnome\\.Nautilus$" },
	float = true,
})

hl.window_rule({
	name = "steam-client",
	match = { class = "^(steam|Steam)$" },
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "battlenet",
	match = { class = "steam_app_0", title = "Battle.net" },
	no_focus = true,
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "battlenet-login",
	match = { class = "steam_app_0", title = "Battle\\.net Login" },
	no_focus = true,
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "tidal",
	match = { class = "tidal-hifi" },
	workspace = "name:Discord",
})

hl.window_rule({
	name = "discord",
	match = { title = "Discord" },
	no_focus = true,
	workspace = "name:Discord",
})

hl.window_rule({
	name = "ghostty-appid",
	match = { class = "com\\.mitchellh\\.ghostty" },
	fullscreen = false,
	opacity = 0.9,
})

hl.window_rule({
	name = "kitty",
	match = { title = "kitty" },
	fullscreen = false,
})

hl.window_rule({
	name = "solaar",
	match = { class = "solaar" },
	workspace = "name:Discord",
})

hl.window_rule({
	name = "gamescope",
	match = { class = "gamescope" },
	fullscreen = true,
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "lutris",
	match = { class = "^lutris$" },
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "bottles",
	match = { class = "^bottles$" },
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "faugus",
	match = { class = "^faugus-launcher$" },
	workspace = "name:Gaming",
})

hl.window_rule({
	name = "kdevelop",
	match = { class = "org\\.kde\\.kdevelop" },
	fullscreen = true,
})

hl.window_rule({
	name = "via",
	match = { class = "via-nativia", title = "Via" },
	workspace = "name:Discord",
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

-- hl.window_rule({
-- 	name = "firefox",
-- 	match = { class = "^firefox$" },
-- 	workspace = "2",
-- })

hl.window_rule({
	name = "vesktop",
	match = { class = "^vesktop$" },
	workspace = "name:Discord",
})

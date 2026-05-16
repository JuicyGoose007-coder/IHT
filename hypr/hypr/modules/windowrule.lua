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
	name = "float-xdg-portal",
	match = { class = "^xdg-desktop-portal$" },
	float = true,
})

hl.window_rule({
	name = "steam-client",
	match = { class = "^steam$" },
	no_focus = true,
	workspace = "Gaming",
})

hl.window_rule({
	name = "battlenet",
	match = { class = "steam_app_0", title = "Battle.net" },
	no_focus = true,
	workspace = "Gaming",
})

hl.window_rule({
	name = "battlenet-login",
	match = { class = "steam_app_0", title = "Battle\\.net Login" },
	no_focus = true,
	workspace = "Gaming",
})

hl.window_rule({
	name = "tidal",
	match = { class = "tidal-hifi" },
	workspace = "Discord",
})

hl.window_rule({
	name = "discord",
	match = { title = "Discord" },
	no_focus = true,
	workspace = "Discord",
	inactive_opacity = 0.9,
})

hl.window_rule({
	name = "ghostty",
	match = { title = "ghostty" },
	fullscreen = false,
	focus = true,
	inactive_opacity = 0.9,
})

hl.window_rule({
	name = "ghostty-appid",
	match = { class = "com\\.mitchellh\\.ghostty" },
	fullscreen = false,
	focus = true,
	inactive_opacity = 0.9,
})

hl.window_rule({
	name = "kitty",
	match = { title = "kitty" },
	fullscreen = false,
	focus = true,
	inactive_opacity = 0.9,
})

hl.window_rule({
	name = "solaar",
	match = { class = "solaar" },
	workspace = "Discord",
	inactive_opacity = 0.9,
})

hl.window_rule({
	name = "gamescope",
	match = { class = "gamescope" },
	fullscreen = true,
	workspace = "Gaming",
	focus = true,
})

hl.window_rule({
	name = "kdevelop",
	match = { class = "org\\.kde\\.kdevelop" },
	fullscreen = 2,
	focus = true,
	inactive_opacity = 0.9,
})

hl.window_rule({
	name = "via",
	match = { class = "via-nativia", title = "Via" },
	workspace = "Discord",
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

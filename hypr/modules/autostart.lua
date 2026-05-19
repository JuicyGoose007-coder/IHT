-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
	-- hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("~/.config/waybar/waybar.sh")
	hl.exec_cmd("hymission")
	hl.exec_cmd("swaync")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("ghostty", { workspace = "name:Main" })
	hl.exec_cmd("firefox", { workspace = "name:Main" })
	-- hl.exec_cmd("steam")
	hl.exec_cmd("vesktop")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("hyprctl dispatch workspace name:Gaming")
end)

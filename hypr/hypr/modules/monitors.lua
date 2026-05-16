------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "DP-2",
	mode = "2560x1440@165.999",
	position = "1920x0",
	scale = 1,
	vrr = 2,
})

hl.monitor({
	output = "DP-1",
	mode = "1920x1080@60.000",
	position = "0x0",
	scale = 1,
})

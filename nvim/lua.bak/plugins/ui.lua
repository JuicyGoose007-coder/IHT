return {
	-- Custom dashboard + disable snacks file explorer sidebar
	{
		"folke/snacks.nvim",
		opts = {
			explorer = { enabled = false },
			dashboard = {
				preset = {
					header = table.concat({
						"",
						"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
						"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
						"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
						"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
						"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
						"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
						"",
						"                     ネオヴィム                     ",
						"",
					}, "\n"),
				},
			},
		},
	},

	-- Disable blink.cmp ghost text (Supermaven handles this)
	{
		"saghen/blink.cmp",
		opts = {
			completion = {
				ghost_text = { enabled = false },
			},
		},
	},

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = true },
		},
	},
}

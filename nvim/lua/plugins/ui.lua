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

return {
	-- Disable LazyVim's built-in neo-tree (using yazi/superfile instead)
	{ "nvim-neo-tree/neo-tree.nvim", enabled = false },

	-- File explorer (yazi - terminal file manager)
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		dependencies = { "folke/snacks.nvim" },
		keys = {
			{
				"<leader>e",
				"<cmd>Yazi<cr>",
				desc = "Open yazi (current file)",
			},
			{
				"<leader>E",
				"<cmd>Yazi cwd<cr>",
				desc = "Open yazi (cwd)",
			},
		},
		opts = {
			open_for_directories = true, -- Replace netrw for directories
			floating_window_scaling_factor = 0.9,
			yazi_floating_window_border = "rounded",
		},
	},
}

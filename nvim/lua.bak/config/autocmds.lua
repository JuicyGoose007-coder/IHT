-- Auto-reload files when focus returns or buffer is entered
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	command = "checktime",
})

-- Override LazyVim's <C-hjkl> window nav with vim-tmux-navigator.
-- vim.schedule_wrap ensures this runs after ALL VeryLazy handlers (including LazyVim's keymaps) finish.
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = vim.schedule_wrap(function()
		vim.keymap.set(
			{ "n", "v", "i" },
			"<C-h>",
			"<cmd>TmuxNavigateLeft<cr>",
			{ silent = true, desc = "Navigate left" }
		)
		vim.keymap.set(
			{ "n", "v", "i" },
			"<C-j>",
			"<cmd>TmuxNavigateDown<cr>",
			{ silent = true, desc = "Navigate down" }
		)
		vim.keymap.set({ "n", "v", "i" }, "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true, desc = "Navigate up" })
		vim.keymap.set(
			{ "n", "v", "i" },
			"<C-l>",
			"<cmd>TmuxNavigateRight<cr>",
			{ silent = true, desc = "Navigate right" }
		)
	end),
})

return {
	{ "yetone/avante.nvim", enabled = false },

	-- Supermaven (AI inline code completion - full line/multi-line suggestions)
	{
		"supermaven-inc/supermaven-nvim",
		opts = {
			keymaps = {
				accept_suggestion = "<Tab>",
				clear_suggestion = "<C-]>",
				accept_word = "<M-e>",
			},
		},
	},

	-- Codecompanion (AI chat/completion using Ollama - no API key needed)
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			strategies = {
				chat = { adapter = "ollama" },
				inline = { adapter = "ollama" },
			},
			adapters = {
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							model = { default = "qwen2.5-coder:7b" },
						},
					})
				end,
			},
		},
		keys = {
			{ "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat" },
			{ "<leader>ai", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
			{ "<leader>ai", "<cmd>CodeCompanionActions<cr>", mode = "v", desc = "AI Actions" },
		},
	},
}

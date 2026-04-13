return {
	-- Fuzzy finder (fzf-lua - faster than telescope)
	{
		"ibhagwan/fzf-lua",
		config = function(_, opts)
			opts.ui_select = nil
			require("fzf-lua").setup(opts)
		end,
		keys = {
			{
				"<leader>/",
				function()
					require("fzf-lua").blines()
				end,
				desc = "Search current file",
			},
		},
	},

	-- Treesitter (better syntax highlighting + code awareness)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"python",
				"lua",
				"vim",
				"vimdoc",
				"json",
				"yaml",
				"markdown",
				"bash",
				"rust",
				"c",
				"cpp",
				"go",
				"java",
				"javascript",
				"typescript",
				"css",
				"html",
				"graphql",
				"json5",
				"php",
				"sql",
				"svelte",
				"toml",
				"xml",
				"zig",
			},
			highlight = { enable = true },
			indent = { enable = true },
		},
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "Harpoon add file" })
			vim.keymap.set("n", "<leader>hh", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon menu" })

			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon file 1" })
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon file 2" })
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon file 3" })
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon file 4" })
		end,
	},
}

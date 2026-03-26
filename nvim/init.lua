-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 4 -- 4-space tabs
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- Spaces instead of tabs
vim.opt.smartindent = true
vim.opt.wrap = true -- Enable wrap
vim.opt.linebreak = true
vim.opt.list = false
vim.opt.breakindent = true
vim.opt.termguicolors = true -- True color support
vim.opt.scrolloff = 8 -- Keep 8 lines visible when scrolling
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.autoread = true -- Auto-reload files changed outside nvim

-- Auto-reload files when focus returns or buffer is entered
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	command = "checktime",
})

-- Navigate visual lines when wrap is on
vim.keymap.set("n", "j", "gj", { desc = "Move down visual line" })
vim.keymap.set("n", "k", "gk", { desc = "Move up visual line" })

-- Setup plugins
require("lazy").setup({
	-- LazyVim (core framework)
	{
		"LazyVim/LazyVim",
		import = "lazyvim.plugins",
		opts = {
			colorscheme = "oxocarbon",
		},
	},

	-- Colorscheme
	{
		"nyoom-engineering/oxocarbon.nvim",
		-- Add in any other configuration;
		-- event = foo,
		-- config = bar
		-- end,
	},

	-- Disable LazyVim's built-in neo-tree (using yazi/superfile instead)
	{ "nvim-neo-tree/neo-tree.nvim", enabled = false },
	{ "yetone/avante.nvim", enabled = false },

	-- File explorer (superfile - terminal file manager)
	{
		"anaypurohit0907/superfile.nvim",
		main = "superfile",
		opts = { key = false },
		keys = {
			{
				"<C-s>", --change this to any keybing you want
				function()
					require("superfile").open()
				end,
				mode = { "n", "t" },
				desc = "Open/Focus Superfile",
				silent = true,
			},
		},
	},

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

	-- Python support
	{ import = "lazyvim.plugins.extras.lang.python" },

	-- Custom dashboard (overrides LazyVim's snacks.nvim dashboard)
	{
		"folke/snacks.nvim",
		opts = {
			explorer = { enabled = false }, -- Disable snacks file explorer sidebar
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

	-- Fuzzy finder (fzf-lua - faster than telescope)
	{ import = "lazyvim.plugins.extras.editor.fzf" },
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

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = true },
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
			},
			highlight = { enable = true },
			indent = { enable = true },
		},
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Snipe (quick buffer navigation)
	-- {
	-- 	"leath-dub/snipe.nvim",
	-- 	config = function()
	-- 		local snipe = require("snipe")
	-- 		snipe.setup({
	-- 			ui = {
	-- 				position = "center",
	-- 				text_align = "file-first",
	-- 				open_win_override = {
	-- 					border = "rounded",
	-- 					title = " 󰈙 Buffers ",
	-- 					title_pos = "center",
	-- 				},
	-- 			},
	-- 			sort = "last",
	-- 			navigate = {
	-- 				cancel_snipe = "<esc>",
	-- 				close_buffer = "d", -- Press d to delete buffer from list
	-- 			},
	-- 		})
	--
	-- 		vim.keymap.set("n", "<leader>hh", function()
	-- 			snipe.open_buffer_menu()
	-- 		end, { desc = "Snipe buffer menu" })
	-- 	end,
	-- },

	-- Supermaven (AI inline code completion - full line/multi-line suggestions)
	{
		"supermaven-inc/supermaven-nvim",
		opts = {
			keymaps = {
				accept_suggestion = "<Tab>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-f>",
			},
		},
	},

	-- Seamless pane/split navigation between tmux and neovim
	{ "christoomey/vim-tmux-navigator", lazy = false },

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

	-- Mason (automatically installs LSP servers)
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"typescript-language-server",
				"html-lsp",
				"css-lsp",
				"lua-language-server",
				"bash-language-server",
				"json-lsp",
				"yaml-language-server",
				"rust-analyzer",
				"gopls",
				"clangd",
				"taplo",
				"marksman",
				"prettier",
			},
		},
	},

	-- LSP config (LazyVim handles setup; just override lua_ls settings)
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							telemetry = { enable = false },
						},
					},
				},
			},
		},
	},
}, {
	defaults = { lazy = false },
	checker = { enabled = true }, -- Auto-check for plugin updates
})

-- Override LazyVim's <C-hjkl> window nav with vim-tmux-navigator.
-- vim.schedule_wrap ensures this runs after ALL VeryLazy handlers (including LazyVim's keymaps) finish.
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = vim.schedule_wrap(function()
		vim.keymap.set({ "n", "v", "i" }, "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  { silent = true, desc = "Navigate left" })
		vim.keymap.set({ "n", "v", "i" }, "<C-j>", "<cmd>TmuxNavigateDown<cr>",  { silent = true, desc = "Navigate down" })
		vim.keymap.set({ "n", "v", "i" }, "<C-k>", "<cmd>TmuxNavigateUp<cr>",    { silent = true, desc = "Navigate up" })
		vim.keymap.set({ "n", "v", "i" }, "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true, desc = "Navigate right" })
	end),
})

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.opt.syntax = "off"

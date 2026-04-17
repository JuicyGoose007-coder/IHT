-- Bootstrap packages
vim.pack.add({ { src = "https://github.com/nvim-lua/plenary.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/nvim-tree/nvim-web-devicons" } }, { load = true })
vim.pack.add({ { src = "https://github.com/echasnovski/mini.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } }, { load = true })
vim.pack.add({ { src = "https://github.com/nyoom-engineering/oxocarbon.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/mason-org/mason.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/christoomey/vim-tmux-navigator" } }, { load = true })
vim.pack.add({ { src = "https://github.com/Saghen/blink.cmp", build = "cargo build --release" } }, { load = true })
vim.pack.add({ { src = "https://github.com/rafamadriz/friendly-snippets" } }, { load = true })
vim.pack.add({ { src = "https://github.com/jiaoshijie/undotree" } }, { load = true })
vim.pack.add({ { src = "https://github.com/ibhagwan/fzf-lua" } }, { load = true })
vim.pack.add({ { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" } }, { load = true })
vim.pack.add({ { src = "https://github.com/lukas-reineke/indent-blankline.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/nvimdev/dashboard-nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/mg979/vim-visual-multi" } }, { load = true })

-- Leader keys (must be before keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.autoread = true
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true

-- Colorscheme
vim.cmd.colorscheme("oxocarbon")

-- Force Transparent background
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

-- Mini (kept for ai, operators, pairs, surround — no good replacements)
require("mini.ai").setup()
require("mini.operators").setup()
require("mini.pairs").setup()
require("mini.surround").setup()

-- Dashboard
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dashboard",
	once = true,
	callback = function()
		vim.b.miniindentscope_disable = true
		require("ibl").setup_buffer(0, { enabled = false })
		vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#33b1ff", bold = true })
		vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#525252", italic = true })
		vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = "#ee5396" })
		vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#dde1e7" })
		vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#42be65" })
	end,
})
require("dashboard").setup({
	theme = "hyper",
	config = {
		header = {
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
		},
		shortcut = {
			{
				desc = "  Files",
				group = "DashboardShortCut",
				action = "FzfLua files",
				key = "f",
			},
			{
				desc = "  Grep",
				group = "DashboardShortCut",
				action = "FzfLua live_grep",
				key = "g",
			},
			{
				desc = "  Config",
				group = "DashboardShortCut",
				action = "edit ~/.config/nvim/init.lua",
				key = "c",
			},
			{
				desc = "  Explorer",
				group = "DashboardShortCut",
				action = "Oil",
				key = "e",
			},
			{
				desc = "  New File",
				group = "DashboardShortCut",
				action = function()
					vim.ui.input({ prompt = "New file: " }, function(input)
						if input and input ~= "" then
							vim.cmd("edit " .. vim.fn.fnameescape(input))
						end
					end)
				end,
				key = "n",
			},
			{
				desc = "  Quit",
				group = "DashboardShortCut",
				action = "qa",
				key = "q",
			},
		},
		footer = { "", "  neovim  —  stay sharp" },
	},
})

-- Statusline
vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "#161616", bg = "#33b1ff", bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = "#161616", bg = "#78a9ff", bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = "#161616", bg = "#ee5396", bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = "#161616", bg = "#ff7eb6", bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = "#161616", bg = "#be95ff", bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = "#dde1e7", bg = "#262626" })
vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = "#525252", bg = "#161616" })
vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = "#525252", bg = "#161616" })
require("mini.statusline").setup()

-- Which-key
require("which-key").setup()

-- Indent guides
require("ibl").setup({
	indent = { char = "│" },
	scope = { enabled = true },
})

-- File explorer
require("oil").setup({
	view_options = { show_hidden = true },
})

-- Undotree
require("undotree").setup()

-- Fuzzy finder
require("fzf-lua").setup()

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()

-- Completion
require("blink.cmp").setup({
	keymap = { preset = "enter" },
	completion = {
		ghost_text = {
			enabled = true,
			show_without_selection = true,
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
})

-- Treesitter
require("nvim-treesitter.config").setup({
	ensure_installed = {
		"python",
		"lua",
		"rust",
		"html",
		"css",
		"toml",
		"json",
		"yaml",
		"vim",
		"vimdoc",
		"markdown",
	},
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- LSP
require("mason").setup()

local lsp_servers = { "pyright", "lua_ls", "rust_analyzer", "html", "cssls", "taplo", "yamlls", "jsonls" }
for _, server in ipairs(lsp_servers) do
	vim.lsp.config(server, {})
end
vim.lsp.enable(lsp_servers)

-- Diagnostics
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
})

-- Formatting
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_organize_imports", "ruff_format" },
		rust = { "rustfmt" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		toml = { "taplo" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

-- Keymaps

-- Save / quit
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>so", "<cmd>so %<cr>", { desc = "Source file" })

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })

-- Git
vim.keymap.set("n", "<leader>gg", function()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})
	vim.fn.termopen("lazygit", {
		on_exit = function()
			vim.api.nvim_buf_delete(buf, { force = true })
		end,
	})
	vim.cmd.startinsert()
end, { desc = "Lazygit" })

-- Fuzzy finder
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua blines<cr>", { desc = "Search current file" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua commands<cr>", { desc = "Commands" })

-- Harpoon
vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end, { desc = "Harpoon add file" })
vim.keymap.set("n", "<leader>hh", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon menu" })
for i = 1, 4 do
	vim.keymap.set("n", "<leader>" .. i, function()
		harpoon:list():select(i)
	end, { desc = "Harpoon file " .. i })
end

-- LSP (gR for references — gr reserved for mini.operators replace)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gR", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

-- Format
vim.keymap.set("n", "<leader>cf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format file" })

-- Undotree
vim.keymap.set("n", "<leader>~", "<cmd>lua require('undotree').toggle()<cr>", { desc = "Undotree" })

-- Tmux navigation
for key, dir in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
	vim.keymap.set({ "n", "v", "i" }, "<C-" .. key .. ">", "<cmd>TmuxNavigate" .. dir .. "<cr>", { silent = true })
end

-- Visual line navigation
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- n/N keep search centered
vim.keymap.set("n", "n", "nzzzv", { silent = true })
vim.keymap.set("n", "N", "Nzzzv", { silent = true })

-- Esc clears search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Buffer switching
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Move lines
vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set(
	"v",
	"<A-k>",
	":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
	{ desc = "Move selection up" }
)

-- Indenting keeps visual selection
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Centered scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Join lines keep cursor position
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })

-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete to void" })

-- Visual paste without yanking replaced text
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Replace word under cursor across file
vim.keymap.set("n", "<leader>rw", function()
	local word = vim.fn.expand("<cword>")
	local cmd = ":%s/\\<" .. word .. "\\>//gc<Left><Left><Left>"
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)
end, { desc = "Replace word under cursor" })

-- Autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	command = "checktime",
})

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

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
	{
		"LazyVim/LazyVim",
		import = "lazyvim.plugins",
		opts = {
			colorscheme = "oxocarbon",
		},
	},
	{ import = "lazyvim.plugins.extras.editor.fzf" },
	{ import = "lazyvim.plugins.extras.lang.python" },
	{ import = "plugins" },
}, {
	defaults = { lazy = false },
	checker = { enabled = true }, -- Auto-check for plugin updates
})

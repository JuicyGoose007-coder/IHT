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

-- Auto format on save
vim.g.autoformat = true

-- Transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

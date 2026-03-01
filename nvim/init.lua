-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true         -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 4           -- 4-space tabs
vim.opt.shiftwidth = 4
vim.opt.expandtab = true      -- Spaces instead of tabs
vim.opt.smartindent = true
vim.opt.wrap = false          -- No line wrap
vim.opt.termguicolors = true  -- True color support
vim.opt.scrolloff = 8         -- Keep 8 lines visible when scrolling
vim.opt.signcolumn = "yes"    -- Always show sign column

-- Setup plugins
require("lazy").setup({
  -- LazyVim (core framework)
  {
    "LazyVim/LazyVim",
    import = "lazyvim.plugins",
  },

  -- Colorscheme
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme carbonfox")
    end,
  },

  -- File explorer
  { import = "lazyvim.plugins.extras.editor.neo-tree" },

  -- Python support
  { import = "lazyvim.plugins.extras.lang.python" },

  -- Custom dashboard (overrides LazyVim's snacks.nvim dashboard)
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "                                                                      ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗               ",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║               ",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║               ",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║               ",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║               ",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝               ",
            "                                                                      ",
            "                        ネオヴィム                                   ",
            "                                                                      ",
          }, "\n"),
        },
      },
    },
  },

  -- Fuzzy finder (fzf-lua - faster than telescope)
  { import = "lazyvim.plugins.extras.editor.fzf" },
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>/", function() require("fzf-lua").blines() end, desc = "Search current file" },
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
        "python", "lua", "vim", "vimdoc",
        "json", "yaml", "markdown", "bash",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Harpoon (quick file bookmarking)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Keymaps
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,          { desc = "Harpoon add file" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,      { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,      { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,      { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,      { desc = "Harpoon file 4" })
    end,
  },

  -- Mason (automatically installs LSP servers)
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "pyright",       -- Python
        "ts_ls",         -- TypeScript / JavaScript
        "html",          -- HTML
        "cssls",         -- CSS
        "lua_ls",        -- Lua
        "bashls",        -- Bash
        "jsonls",        -- JSON
        "yamlls",        -- YAML
        "rust_analyzer", -- Rust
        "gopls",         -- Go
        "clangd",        -- C / C++
        "taplo",         -- TOML
        "marksman",      -- Markdown
      },
      automatic_installation = true,
    },
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = ok and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

      local servers = {
        "pyright", "ts_ls", "html", "cssls", "lua_ls",
        "bashls", "jsonls", "yamlls", "rust_analyzer",
        "gopls", "clangd", "taplo", "marksman",
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities })
      end

      -- Tell lua_ls about the vim global so it stops warning
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })

      -- Keymaps (only active when LSP is attached to a buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,      vim.tbl_extend("force", opts, { desc = "Find references" }))
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,           vim.tbl_extend("force", opts, { desc = "Hover docs" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,     vim.tbl_extend("force", opts, { desc = "Code action" }))
          vim.keymap.set("n", "<leader>d",  vim.diagnostic.open_float,   vim.tbl_extend("force", opts, { desc = "Show diagnostics" }))
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,    vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,    vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        end,
      })
    end,
  },
}, {
  defaults = { lazy = false },
  checker = { enabled = true }, -- Auto-check for plugin updates
})

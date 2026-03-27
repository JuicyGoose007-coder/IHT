return {
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
}

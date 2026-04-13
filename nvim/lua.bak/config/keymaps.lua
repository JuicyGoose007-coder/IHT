-- NOTE: LazyVim already handles j/k visual line navigation, n/N search centering,
-- Alt-j/k line moving, Shift-H/L buffer switching, and Esc clearing search.

-- Keep cursor centered when scrolling half-pages
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor position when joining lines (J normally jumps cursor)
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Clipboard: yank/paste to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "paste from clipboard" })

-- Delete without polluting the yank register
vim.keymap.set({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete to void" })

-- Visual paste without yanking the replaced text
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Substitute word under cursor across file. Type replacement, then Enter.
-- c=confirm each match with y/n/a/q
vim.keymap.set("n", "<leader>rw", function()
	local word = vim.fn.expand("<cword>")
	local cmd = ":%s/\\<" .. word .. "\\>//gc<Left><Left><Left>"
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)
end, { desc = "Replace word under cursor" })

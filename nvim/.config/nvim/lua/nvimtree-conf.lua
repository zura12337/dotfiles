require("nvim-tree").setup({
	update_cwd = true,
	update_focused_file = {
		update_cwd = true,
	},
	view = {
		width = 35,
		side = "right",
	},
})

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map("n", "<A-,>", ":BufferMovePrevious<CR>", opts)
map("n", "<A-.>", ":BufferMoveNext<CR>", opts)
-- Goto buffer in position...
-- Close buffer
map("n", "<A-c>", ":BufferClose<CR>", opts)
-- Sort automatically by...
map("n", "<Space>bb", ":BufferOrderByBufferNumber<CR>", opts)
map("n", "<Space>bd", ":BufferOrderByDirectory<CR>", opts)
map("n", "<Space>bl", ":BufferOrderByLanguage<CR>", opts)

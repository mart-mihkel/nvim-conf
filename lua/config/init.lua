require("config.map")
require("config.opt")
require("config.init_lazy")

vim.o.background = "light"
vim.g.netrw_banner = false
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

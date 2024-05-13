vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- configure wgsl filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	desc = "Associate WebGPU Shading Language filetype",
	pattern = "*.wgsl",
	callback = function()
		vim.bo.filetype = "wgsl"
	end,
})

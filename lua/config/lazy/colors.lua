return {
	"projekt0n/github-nvim-theme",
	lazy = false,
	priority = 1024,
	config = function()
		local black = { base = "#1f2328", bright = "#e0e2ea" }
		local white = { bg = "#ffffff", fg = "#ffffff" }

		require("github-theme").setup({
			options = { hide_end_of_buffer = false },
			palettes = {
				github_light = {
					blue = black,
				},
			},
		})

		vim.api.nvim_set_hl(0, "TelescopePromptBorder", white)
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", white)
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", white)

		vim.cmd("colorscheme github_light")
	end,
}

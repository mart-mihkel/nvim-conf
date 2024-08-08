return {
	"projekt0n/github-nvim-theme",
	lazy = false,
	priority = 1024,
	config = function()
		local black = { base = "#000000", bright = "#1f2328" }
		local telescope_border = { bg = "#e2e8f0", fg = "#e2e8f0" }

		require("github-theme").setup({
			options = { hide_end_of_buffer = false },
			palettes = {
				github_light_high_contrast = {
					blue = black,
				},
			},
		})

		vim.api.nvim_set_hl(0, "TelescopePromptBorder", telescope_border)
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", telescope_border)
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", telescope_border)

		vim.cmd("colorscheme github_light_high_contrast")
	end,
}

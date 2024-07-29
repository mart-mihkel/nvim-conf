return {
	"projekt0n/github-nvim-theme",
	lazy = false,
	priority = 1024,
	config = function()
		require("github-theme").setup({
			options = { hide_end_of_buffer = false },
			palettes = {
				github_light = {
					blue = { base = "#000000", bright = "#0a0a0a" },
				},
			},
		})

		vim.cmd("colorscheme github_light")
	end,
}

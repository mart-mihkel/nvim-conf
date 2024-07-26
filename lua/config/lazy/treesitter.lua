return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"rust",
				"bash",
				"html",
				"jsdoc",
				"vimdoc",
				"python",
				"markdown",
				"typescript",
			},

			modules = {},

			sync_install = false,
			auto_install = true,
			ignore_install = {},

			indent = { enable = true },
			highlight = { enable = true },
		})
	end,
}

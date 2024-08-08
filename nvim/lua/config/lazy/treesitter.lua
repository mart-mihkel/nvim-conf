return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"go",
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

			ignore_install = {},
			modules = {},

			sync_install = false,
			auto_install = true,

			indent = { enable = true },
			highlight = { enable = true },
		})
	end,
}

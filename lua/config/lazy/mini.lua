return {
	"echasnovski/mini.nvim",
	config = function()
		require("mini.ai").setup({ n_lines = 512 })
		require("mini.diff").setup({ view = { style = "sign", signs = { add = "+", change = "~", delete = "-" } } })
		require("mini.pairs").setup()
		require("mini.comment").setup()
		require("mini.surround").setup()
	end,
}

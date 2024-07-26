return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		icons = { mappings = false },
		spec = {
			{ "<leader>c", group = "[C]ode" },
			{ "<leader>d", group = "[D]ocument" },
			{ "<leader>r", group = "[R]ename" },
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>w", group = "[W]orkspace" },
		},
	},
}

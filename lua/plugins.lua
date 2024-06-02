-- [[ Configure and install plugins ]]

-- Detect tabstop and shiftwidth automatically
local sleuth = { "tpope/vim-sleuth" }

-- "gc" to comment visual regions/lines
local comment = { "numToStr/Comment.nvim", opts = {} }

-- Highlight todo, notes, etc in comments
local plenary = { "nvim-lua/plenary.nvim" }
local todo_comments = {
	"folke/todo-comments.nvim",
	event = "VimEnter",
	dependencies = { plenary },
	opts = { signs = false },
}

-- Git related signs to the gutter, utilities for managing changes
local gitsigns = {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	},
}

-- Useful plugin to show you pending keybinds.
local whichkey = {
	"folke/which-key.nvim",
	event = "VimEnter",
	config = function()
		require("which-key").setup()
		require("which-key").register({
			["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
			["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
			["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
			["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
			["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
		})
	end,
}

-- Fuzzy Finder (files, lsp, etc)
local telescope_fzf_native = { -- If encountering errors, see telescope-fzf-native README for install instructions
	"nvim-telescope/telescope-fzf-native.nvim",
	build = "make",
	cond = function()
		return vim.fn.executable("make") == 1
	end,
}
local telescope_ui_select = { "nvim-telescope/telescope-ui-select.nvim" }

local telescope = {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = { plenary, telescope_fzf_native, telescope_ui_select },
	config = function()
		-- [[ Configure Telescope ]]
		require("telescope").setup({
			defaults = {
				path_display = function(_, path)
					local tail = require("telescope.utils").path_tail(path)
					return string.format("%s (%s)", tail, path)
				end,
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						width = { padding = 4 },
						heigth = { padding = 4 },
					},
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		-- Enable telescope extensions, if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		-- Keymaps
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		vim.keymap.set("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
}

-- LSP Configuration & Plugins
local mason = { "williamboman/mason.nvim" }
local mason_lspconfig = { "williamboman/mason-lspconfig.nvim" }
local mason_tool_installer = { "WhoIsSethDaniel/mason-tool-installer.nvim" }
local fidget = { "j-hui/fidget.nvim", opts = {} }

local lspconfig = {
	"neovim/nvim-lspconfig",
	dependencies = { mason, mason_lspconfig, mason_tool_installer, fidget },
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Keymaps
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- Highlight word on hover
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		--  Broadcast new capabilities to the LSPs
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Enable language servers
		-- cmd (table): Override the default command used to start the server
		-- filetypes (table): Override the default list of associated filetypes for the server
		-- capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		-- settings (table): Override the default settings passed when initializing the server.
		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								"${3rd}/luv/library",
								unpack(vim.api.nvim_get_runtime_file("", true)),
							},
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
		}

		-- Ensure the servers and tools above are installed
		require("mason").setup()

		local ensure_installed = vim.tbl_keys(servers)
		vim.list_extend(ensure_installed, { "stylua" })

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- Override only explicitly passed values
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}

-- Highlight, edit, and navigate code
local treesitter = {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		-- [[ Configure Treesitter ]]

		---@diagnostic disable-next-line: missing-fields
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "bash", "c", "html", "lua", "markdown", "vim", "vimdoc", "rust", "python" },
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}

-- Autoformat
local conform = {
	"stevearc/conform.nvim",
	opts = {
		notify_on_error = false,
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			rust = { "rustfmt" },
			["_"] = { "trim_whitespace" },
		},
	},
}

-- Autocompletion
-- Snippet Engine & its associated nvim-cmp source
local lua_snip = {
	"L3MON4D3/LuaSnip",
	build = (function()
		if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
			return
		end
		return "make install_jsregexp"
	end)(),
}
local cmp_luasnip = "saadparwaiz1/cmp_luasnip"
local cmp_nvim_lsp = "hrsh7th/cmp-nvim-lsp"
local cmp_path = "hrsh7th/cmp-path"

local nvim_cmp = {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = { lua_snip, cmp_luasnip, cmp_nvim_lsp, cmp_path },
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		luasnip.config.setup({})

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			completion = { completeopt = "menu,menuone,noinsert" },
			mapping = cmp.mapping.preset.insert({
				-- Select the [n]ext item
				["<C-n>"] = cmp.mapping.select_next_item(),
				-- Select the [p]revious item
				["<C-p>"] = cmp.mapping.select_prev_item(),
				-- Accept ([y]es) the completion.
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping.confirm({ select = true }),
				-- Manually trigger a completion from nvim-cmp.
				["<C-Space>"] = cmp.mapping.complete({}),

				-- <c-l> will move you to the right of each of the expansion locations.
				-- <c-h> is similar, except moving you backwards.
				["<C-l>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),
				["<C-h>"] = cmp.mapping(function()
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),
			}),
			sources = {
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "path" },
			},
		})
	end,
}

-- Status line
local nvim_web_devicons = "nvim-tree/nvim-web-devicons"

local lualine = {
	"nvim-lualine/lualine.nvim",
	dependencies = { nvim_web_devicons },
	config = function()
		require("lualine").setup()
	end,
}

-- Colorscheme
local tokyonight = {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("tokyonight-day")
	end,
}

-- Collection of various small independent plugins/modules
local mini = {
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		require("mini.ai").setup({ n_lines = 500 })
		-- Add/delete/replace surroundings
		require("mini.surround").setup()
	end,
}

return {
	sleuth,
	comment,
	todo_comments,
	gitsigns,
	whichkey,
	telescope,
	lspconfig,
	treesitter,
	conform,
	nvim_cmp,
	lualine,
	tokyonight,
	mini,
}

return {
	"lewis6991/gitsigns.nvim",
	{
		"andymass/vim-matchup",
		config = function() vim.g.matchup_matchparen_offscreen = { method = "popup" } end,
	},
	{ "windwp/nvim-ts-autotag", config = true },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"stevearc/aerial.nvim",
		opts = {
			layout = {
				min_width = 20,
				max_width = { 30, 0.3 },
			},
			focus_on_open = true,
			close_on_select = true,
			close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
			autojump = true,
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<F4>",
				function() require("aerial").toggle() end,
				desc = "Toggle Aerial",
			},
		},
	},

	-- django
	"tweekmonster/django-plus.vim",

	-- testing
	{
		"andythigpen/nvim-coverage",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { auto_reload = true },
		keys = {
			-- { "<leader>tc", "<cmd>CoverageToggle<cr>", desc = "Toggle coverage signs" },
			-- { "<leader>tC", "<cmd>CoverageSummary<cr>", desc = "Coverage summary" },
		},
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-neotest/neotest-python",
		},
		opts = function() return { adapters = { require("neotest-python") } } end,
	},

	-- lua + neovim
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- snippets
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"molleweide/LuaSnip-snippets.nvim",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
			require("luasnip_snippets").load_snippets()
		end,
	},

	{
		"julienvincent/hunk.nvim",
		cmd = { "DiffEditor" },
		config = function() require("hunk").setup() end,
	},
	{
		"nicolasgb/jj.nvim",
		dependencies = {
			"folke/snacks.nvim", -- Optional, only needed if you use pickers
			"esmuellert/codediff.nvim",
		},
		config = function()
			require("jj").setup({
				diff = {
					backend = vim.fn.system("jj log -r @ --no-graph"):match("default@") and "codediff" or "native",
				},
			})
			local diff = require("jj.diff")
			vim.keymap.set("n", "<leader>d", function()
				local is_empty = vim.fn.system("jj log -r @ --no-graph -T 'empty'"):match("true")
				diff.open_vdiff(is_empty and { rev = "@--" } or nil)
			end, { desc = "JJ diff current buffer" })
		end,
	},
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		opts = {
			diff = { compute_moves = true },
		},
	},
}

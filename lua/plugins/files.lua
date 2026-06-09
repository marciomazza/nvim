return {

	"wsdjeg/vim-fetch",
	{
		"dmtrKovalenko/fff.nvim",
		build = function()
			-- downloads a prebuilt binary or falls back to cargo build
			require("fff.download").download_or_build_binary()
		end,
		-- for nixos:
		-- build = "nix run .#release",
		opts = {
			debug = {
				enabled = true,
				show_scores = true,
			},
			layout = {
				height = 1,
				width = 1,
				preview_size = 0.7,
			},
		},
		lazy = false, -- the plugin lazy-initialises itself
		keys = {
			{ "<leader>e", function() require("fff").find_files() end, desc = "FFFind files" },
			{
				"<leader>f",
				function()
					require("fff").live_grep({
						grep = { modes = { "plain", "fuzzy" } },
						query = vim.fn.expand("<cword>"),
					})
				end,
				desc = "Live grep (current word)",
			},
		},
	},
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
		keys = {
			-- { "<leader>f", '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
			{
				"<leader>sw",
				'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
				desc = "Search current word",
			},
			{
				"<leader>sp",
				'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
				desc = "Search on current file",
			},
		},
	},
}

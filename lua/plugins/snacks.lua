return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		git = { enabled = true },
		gitbrowse = { enabled = true },
		image = {
			enabled = true,
			bo = {
				buftype = "nofile",
				bufhidden = "wipe",
				swapfile = false,
				modifiable = false,
			},
		},
		notifier = { enabled = true },
		quickfile = { enabled = true },
		words = { enabled = true },
		picker = {
			enabled = true,
			sources = {
				files = { hidden = true },
			},
		},
	},
	keys = {
		{ "<leader>e", function() Snacks.picker.files() end, desc = "Find Files" },
		{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>sb", function() Snacks.picker.buffers() end, desc = "Buffers" },

		-- git
		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
		{ "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		{ "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
		{ "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
		{ "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
	},
}

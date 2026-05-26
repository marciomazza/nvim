return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		"L3MON4D3/LuaSnip", -- config e deps extras estão em devtools.lua
	},

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		snippets = { preset = "luasnip" },
		keymap = { preset = "super-tab" },
		completion = {
			menu = { border = "rounded" },
			list = { max_items = 100 },
			documentation = {
				auto_show = false,
				window = { border = "rounded" },
			},
		},
		signature = { enabled = true, window = { border = "rounded" } },
		appearance = { use_nvim_cmp_as_default = true },
		sources = {
			per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				lsp = { score_offset = 150, min_keyword_length = 2 },
				snippets = { score_offset = 100 },
				buffer = { score_offset = 80, min_keyword_length = 2 },
			},
		},
	},
}

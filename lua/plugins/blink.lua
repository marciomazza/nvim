return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",
    -- "fang2hou/blink-copilot",
    "Exafunction/windsurf.nvim",
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = "super-tab",
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
    },
    -- completion = { documentation = { auto_show = true } },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        -- "copilot",
        "codeium",
      },
      per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        codeium = { name = "Codeium", module = "codeium.blink", async = true },
        -- copilot = { name = "copilot", module = "blink-copilot", async = true },
      },
    },
    fuzzy = { implementation = "rust" },
  },
  opts_extend = { "sources.default" },
}

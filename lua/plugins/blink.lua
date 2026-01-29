return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",

    -- todo: choose copilot x windosurf x something else
    -- "fang2hou/blink-copilot",
    -- "Exafunction/windsurf.nvim",
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = "enter",
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
    },

    sources = {
      completion = {
        enabled_providers = { "supermaven" },
      },
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        -- todo: choose copilot x windosurf x something else
        -- "copilot",
        -- "codeium",
      },
      per_filetype = { lua = { inherit_defaults = true, "lazydev" } },

      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        lsp = { score_offset = 50 },
        -- todo: choose copilot x windosurf x something else
        -- codeium = { name = "Codeium", module = "codeium.blink", async = true, score_offset = -10 },
        -- copilot = { name = "copilot", module = "blink-copilot", async = true, score_offset = -10 },
        -- copilot = { name = "copilot", module = "blink-copilot", async = true },
        supermaven = {
          name = "supermaven",
          module = "blink.compat.source",
          score_offset = 100,
        },
      },
    },
    fuzzy = { implementation = "rust" },
  },
  opts_extend = { "sources.default" },
}

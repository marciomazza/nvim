return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "giuxtaposition/blink-cmp-copilot",
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = "super-tab" },
    completion = {
      list = {
        selection = { auto_insert = false },
      },
      menu = { border = "rounded" },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      ghost_text = { enabled = true },
    },
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      kind_icons = {
        Copilot = "",
      },
    },
    sources = {
      -- Remover enabled_providers para permitir todos os sources
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "copilot",
      },
      per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        lsp = { score_offset = 50 },
        snippets = { score_offset = 40 },
        buffer = { score_offset = 30, min_keyword_length = 2 },
      },
    },
  },
  opts_extend = { "sources.default" },
}

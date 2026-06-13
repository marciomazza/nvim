-- LuaSnip is installed and configured in devtools.lua
vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

---@module 'blink.cmp'
---@type blink.cmp.Config
require("blink.cmp").setup({
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
})

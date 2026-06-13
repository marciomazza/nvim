pack_changed_hook(
  "LuaSnip",
  function(ev) vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }) end
)

vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/andymass/vim-matchup",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/stevearc/aerial.nvim",
  "https://github.com/tweekmonster/django-plus.vim",
  "https://github.com/folke/lazydev.nvim",
  { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("v2.*") },
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/molleweide/LuaSnip-snippets.nvim",
  "https://github.com/esmuellert/codediff.nvim",
  "https://github.com/nicolasgb/jj.nvim",
})

require("gitsigns").setup()
vim.g.matchup_matchparen_offscreen = { method = "popup" }
require("nvim-ts-autotag").setup()
require("nvim-autopairs").setup()

require("aerial").setup({
  layout = {
    min_width = 20,
    max_width = { 30, 0.3 },
  },
  focus_on_open = true,
  close_on_select = true,
  close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
  autojump = true,
})
vim.keymap.set("n", "<F4>", function() require("aerial").toggle() end, { desc = "Toggle Aerial" })

require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({
  paths = { vim.fn.stdpath("config") .. "/snippets" },
})
require("luasnip_snippets").load_snippets()

require("codediff").setup({
  diff = { compute_moves = true },
})

require("jj").setup({
  diff = {
    backend = vim.fn.system("jj log -r @ --no-graph"):match("default@") and "codediff" or "native",
  },
})
vim.keymap.set("n", "<leader>d", function()
  local is_empty = vim.fn.system("jj log -r @ --no-graph -T 'empty'"):match("true")
  require("jj.diff").open_vdiff(is_empty and { rev = "@--" } or nil)
end, { desc = "JJ diff current buffer" })

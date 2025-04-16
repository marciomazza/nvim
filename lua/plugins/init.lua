return {

  -- basic
  "tpope/vim-sensible",
  "tpope/vim-abolish",
  "tpope/vim-fugitive",
  "tpope/vim-repeat",         -- XXX still needed?
  "terryma/vim-multiple-cursors",
  "farmergreg/vim-lastplace", -- remember cursor position on file reopen

  -- files
  { "junegunn/fzf",              dir = "~/.fzf",               build = "./install --all" },
  "wsdjeg/vim-fetch",

  -- programming in general
  "tweekmonster/django-plus.vim", -- django
  {
    "andymass/vim-matchup",
    config = function()
      -- Any additional configuration for vim-matchup can go here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
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
      show_guides = true,
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    keys = {
      { "<F4>", function() require("aerial").toggle() end, desc = "Toggle Aerial" },
    },
  },
  { "andythigpen/nvim-coverage", opts = { auto_reload = true } },
}

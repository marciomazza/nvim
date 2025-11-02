return {

  -- basic
  "mg979/vim-visual-multi",
  "farmergreg/vim-lastplace", -- remember cursor position on file reopen

  -- files
  "junegunn/fzf",
  "wsdjeg/vim-fetch",

  -- programming in general
  "tweekmonster/django-plus.vim", -- django
  {
    "andymass/vim-matchup",
    config = function()
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
      filter_kind = false,
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<F4>",
        function()
          require("aerial").toggle()
        end,
        desc = "Toggle Aerial",
      },
    },
  },
  { "andythigpen/nvim-coverage", dependencies = { "nvim-lua/plenary.nvim" }, opts = { auto_reload = true } },
}

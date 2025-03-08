return {

  -- basic
  "tpope/vim-sensible",
  "tpope/vim-abolish",
  "tpope/vim-fugitive",
  "tpope/vim-repeat",         -- XXX still needed?
  "terryma/vim-multiple-cursors",
  "farmergreg/vim-lastplace", -- remember cursor position on file reopen

  -- files
  { "junegunn/fzf", dir = "~/.fzf", build = "./install --all" },
  "vim-scripts/grep.vim",
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
}

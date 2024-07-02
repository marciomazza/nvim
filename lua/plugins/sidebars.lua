local set_keymap = require "utils".set_keymap

return {
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require "nvim-tree".setup(
        {
          filters = { dotfiles = true, exclude = { ".env", ".gitignore" } },
          actions = { open_file = { quit_on_open = true } }
        }
      )
      set_keymap("n", "<F3>", ":NvimTreeFindFileToggle<CR>")
    end
  },
  {
    "preservim/tagbar",
    config = function()
      set_keymap("n", "<F4>", ":TagbarToggle<CR>")
      vim.g.tagbar_autoclose = 1
      vim.g.tagbar_sort = 0 -- sort by position in file
      vim.g.tagbar_compact = 1
      -- TODO: start folded all but current symbol
      --   this should close all folds, but doesn't
      vim.g.tagbar_foldlevel = 0
    end
  }
}

return {
  {
    "kyazdani42/nvim-tree.lua",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require "nvim-tree".setup(
        {
          filters = { dotfiles = true, exclude = { ".env", ".gitignore" } },
          actions = { open_file = { quit_on_open = true } }
        }
      )
      set_keymap("n", "<F3>", ":NvimTreeToggle<CR>")
    end
  },
  {
    "preservim/tagbar",
    config = function()
      set_keymap("n", "<F4>", ":TagbarToggle<CR>")
      vim.g.tagbar_autoclose = 1
      vim.g.tagbar_sort = 0 -- sort by position in file
    end
  }
}


function nvim_tree_config()
  require('nvim-tree').setup ({
    filters = { dotfiles = true, exclude = {'.env', '.gitignore'} },
    actions = { open_file = { quit_on_open = true } },
  })
  set_keymap('n', '<F3>', ':NvimTreeToggle<CR>')
end

-- preservim/tagbar
set_keymap('n', '<F4>', ':TagbarToggle<CR>')
vim.g.tagbar_autoclose = 1
-- sort by position in file
vim.g.tagbar_sort = 0

return {nvim_tree_config = nvim_tree_config}

-- marciomazza/vim-brogrammer-theme
-- no_buffers_menu silent for the case when the plugin has not yet been installed
vim.cmd('silent! colorscheme brogrammer')

vim.opt.number = true
vim.opt.relativenumber = true

-- luochen1990/rainbow
vim.g.rainbow_active = 1

-- itchyny/lightline.vim & mengelbrecht/lightline-bufferline
vim.g.lightline = {
  colorscheme = 'wombat',
  active= {
    left = { { 'mode', 'paste' },
    { 'gitbranch', 'readonly', 'filename', 'modified' } }
  },
  component_function = { gitbranch = 'FugitiveHead' },
  tabline = { left = {{'buffers'}} , right = {{}} },
  component_expand = { buffers = 'lightline#bufferline#buffers' },
  component_type = { buffers = 'tabsel' },
}
vim.opt.showtabline=2

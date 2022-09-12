vim.cmd.colorscheme 'PaperColor'

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cmdheight = 0  -- autohide the command-line (https://vi.stackexchange.com/a/38231)

-- luochen1990/rainbow
vim.g.rainbow_active = 1

-- itchyny/lightline.vim & mengelbrecht/lightline-bufferline
vim.g.lightline = {
  colorscheme = 'PaperColor',
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

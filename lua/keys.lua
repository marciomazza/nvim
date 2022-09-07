
-- no one is really happy until you have these shortcuts
-- apparently, there's no equivalent to the "cnoreabbrev" in lua
-- https://github.com/nanotee/nvim-lua-guide/issues/37
vim.cmd [[
  cnoreabbrev W! w!
  cnoreabbrev Q! q!
  cnoreabbrev Qall! qall!
  cnoreabbrev Qa! qa!
  cnoreabbrev Wq wq
  cnoreabbrev Wa wa
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
  cnoreabbrev Qa qa
  cnoreabbrev Qall qall
]]

-- Map leader to ,
vim.g.mapleader = ','

local map = vim.api.nvim_set_keymap
options = { noremap = true, silent = true }

-- Clear search highlight
map('n', '<leader><space>', ':noh<cr>', options)

-- Buffer nav
map('n', '<S-Tab>', ':bp<cr>', options)
map('n', '<Tab>', ':bn<cr>', options)

-- Close buffer
map('n', '<leader>c', ':bd<cr>', options)


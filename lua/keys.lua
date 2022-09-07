
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

local set_keymap = require('utils').set_keymap

-- Clear search highlight
set_keymap('n', '<leader><space>', ':noh<cr>')

-- Buffer nav
set_keymap('n', '<S-Tab>', ':bp<cr>')
set_keymap('n', '<Tab>', ':bn<cr>')

-- Close buffer
set_keymap('n', '<leader>c', ':bd<cr>')

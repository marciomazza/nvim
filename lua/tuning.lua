-- The PC is fast enough, do syntax highlight syncing from start
-- TODO probably remove this if start using treesitter
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  command = ":syntax sync fromstart",
})

-- Copy/Paste/Cut with standard clipboard
vim.opt.clipboard = 'unnamed,unnamedplus'

-- Enable hidden buffers
vim.opt.hidden = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase  = true

-- tabstops (may be overriten by autocmd rules)
vim.opt.tabstop     = 2
vim.opt.softtabstop = 0
vim.opt.shiftwidth  = 2
vim.opt.expandtab   = true

local set_keymap = require('utils').set_keymap

-- maintain Visual Mode after shifting > and <
set_keymap('v', '<', '<gv')
set_keymap('v', '>', '>gv')

-- toggle spell check
set_keymap('', '<F6>', ':syntax on<CR>:setlocal spell! spelllang=en_us<CR>')

-- vimdiff -- ignore whitespace differences
vim.opt.diffopt:append {'iwhite'}

-- configure CrispyDrone/vim-tasks
-- TODO run this only on CrispyDrone/vim-tasks context
-- for https://github.com/CrispyDrone/vim-tasks#add-tasks
vim.g.maplocalleader = ' '
vim.g.TasksDateFormat = ''  -- no time marks for @done

-- junegunn/vim-easy-align
set_keymap('n', 'ga', '<Plug>(EasyAlign)')
set_keymap('x', 'ga', '<Plug>(EasyAlign)')

-- grep.vim
set_keymap('n', '<leader>f', ':Rgrep<CR>')
vim.g.Grep_Default_Options = '-IR'
vim.g.Grep_Skip_Files = '*~ ipython_log.py*'
vim.g.Grep_Skip_Dirs = 'RCS CVS SCCS htmlcov .pytest_cache .mypy_cache zz'

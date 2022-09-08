local set_keymap = require('utils').set_keymap

-- grep.vim
set_keymap('n', '<leader>f', ':Rgrep<CR>')
vim.g.Grep_Default_Options = '-IR'
vim.g.Grep_Skip_Files = '*~ ipython_log.py*'
vim.g.Grep_Skip_Dirs = 'RCS CVS SCCS htmlcov .pytest_cache .mypy_cache zz'

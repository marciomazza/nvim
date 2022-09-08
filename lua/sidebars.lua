local set_keymap = require('utils').set_keymap

-- preservim/nerdtree
set_keymap('n', '<F3>', ':NERDTreeToggle<CR>')
vim.g.NERDTreeChDirMode = 2
vim.g.NERDTreeIgnore = {'.rbc$', '\\~$', '.pyc$', '.db$', '.sqlite$', '.git',
                        '__pycache__', '.pytest_cache', '.mypy_cache', 'htmlcov', 'zz*'}
vim.g.NERDTreeSortOrder = {'^__.py$', '/$', '*', '.swp$', '.bak$', '~$'}
vim.g.NERDTreeShowBookmarks = 1
vim.g.nerdtree_tabs_focus_on_files = 1
vim.g.NERDTreeMapOpenInTabSilent = '<RightMouse>'
vim.g.NERDTreeWinSize = 40
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeQuitOnOpen = 1
-- avoid conflict that show brackets on nerdtree
-- https://github.com/luochen1990/rainbow/issues/92
vim.g.rainbow_conf = { separately = { nerdtree = 0 } }

-- majutsushi/tagbar
set_keymap('n', '<F4>', ':TagbarToggle<CR>')
vim.g.tagbar_autoclose = 1
-- sort by position in file
vim.g.tagbar_sort = 0

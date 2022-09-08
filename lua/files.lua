vim.cmd [[

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*~ ipython_log.py*'
let Grep_Skip_Dirs = 'RCS CVS SCCS htmlcov .pytest_cache .mypy_cache zz'

]]

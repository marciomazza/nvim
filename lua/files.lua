
" ctrlpvim/ctrlp.vim
set wildmode=list:longest,list:full
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.db,*.sqlite,*.o,*.obj,.git,*.rbc,*.pyc

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|tox)|node_modules$'
let g:ctrlp_user_command = "find %s -type f | grep -Ev '"+ g:ctrlp_custom_ignore +"'"
let g:ctrlp_use_caching = 0
cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
let g:ctrlp_map = '<leader>e'
let g:ctrlp_open_new_file = 'r'

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*~ ipython_log.py*'
let Grep_Skip_Dirs = 'RCS CVS SCCS htmlcov .pytest_cache .mypy_cache zz'

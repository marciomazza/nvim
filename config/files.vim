
" ctrlpvim/ctrlp.vim
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__,htmlcovi,.pytest_cache
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|tox)|node_modules$'
let g:ctrlp_user_command = "find %s -type f | grep -Ev '"+ g:ctrlp_custom_ignore +"'"
let g:ctrlp_use_caching = 0
cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
let g:ctrlp_map = '<leader>e'
let g:ctrlp_open_new_file = 'r'

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>
""" FIXME understand why grep is not honoring ipython_log.py in wildignore and
"""   probably remove this exclude
let Grep_Default_Options = '-IR --exclude=ipython_log.py --exclude-dir="htmlcov"'

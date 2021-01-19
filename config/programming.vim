
" generall python options
augroup vimrc-python
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
      \ formatoptions+=croq softtabstop=4 smartindent
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
  " ajh17/VimCompletesMe: use omnicompletion with tab just on python files
  autocmd FileType python let b:vcm_tab_complete = "omni"
augroup END
iabbrev pdb breakpoint()

" hdima/python-syntax -- full python syntax highlighting
let g:python_highlight_all = 1

" dense-analysis/ale
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['isort']}
" TODO make mypy togglable?
let g:ale_linters_explicit = 1
let b:ale_linters = {'python': ['flake8']}
let g:ale_pattern_options = {'ipython_log.py': {'ale_enabled': 0}, 'site-packages': {'ale_enabled': 0}}
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
""" make isort match black expectaions
""" see https://github.com/microsoft/vscode-python/issues/6933#issuecomment-543059396
""" TODO observe if this is really working... perhaps have a test?
let g:ale_python_isort_options = '--multi-line=1 --trailing-comma --force-grid-wrap=0 --use-parentheses --line-width=88'

" davidhalter/jedi-vim
let g:jedi#show_call_signatures = "0"
" disable documentation window
set completeopt-=preview

" psf/black  -- apply black on every save
" we would just use black in g:ale_fixers but this should be faster
let g:black_fast = 1
autocmd BufWritePre *.py execute ':Black'

" golang
let g:go_debug=['shell-commands']
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>d <Plug>(go-def)
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

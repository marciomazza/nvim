
" generall python options
augroup vimrc-python
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=100
      \ formatoptions+=croq softtabstop=4 smartindent
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
  " ajh17/VimCompletesMe: use omnicompletion with tab just on python files
  autocmd FileType python let b:vcm_tab_complete = "omni"
augroup END
iabbrev pdb breakpoint()

" python fixers: could use ale fixers, but these look to have better performance
" TODO; confirme this
""" isort uses black profile for compatibility
let g:vim_isort_config_overrides = {'float_to_top': 1, 'profile': 'black'}
let g:black_fast = 1
autocmd BufWritePre *.py execute ':Isort'
autocmd BufWritePre *.py execute ':Black'

" hdima/python-syntax -- full python syntax highlighting
let g:python_highlight_all = 1

" dense-analysis/ale
"" ALE linters & fixers
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace']}
let g:ale_linters_explicit = 1
""" use mypy linter? make it togglable?
let g:ale_linters = {'python': ['flake8']}
let g:ale_python_flake8_options="--ignore E501"
" https://mypy.readthedocs.io/en/latest/running_mypy.html#mapping-file-paths-to-modules
let g:python_mypy_use_global = 1
let g:ale_python_mypy_options = "--namespace-packages --explicit-package-bases"
let g:ale_pattern_options = {'ipython_log.py': {'ale_enabled': 0}, 'site-packages': {'ale_enabled': 0}}
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
"" ALE appearance
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = ' ▶  '
let g:ale_sign_error = '▶'
let g:ale_sign_warning = '▶'
let g:ale_sign_info = '▶'
"" ALE mappings
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" davidhalter/jedi-vim
let g:jedi#show_call_signatures = "0"
" disable documentation window
set completeopt-=preview
let g:jedi#goto_command = "gd"

" golang
let g:go_debug=['shell-commands']
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>d <Plug>(go-def)
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

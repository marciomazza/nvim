
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

" hdima/python-syntax -- full python syntax highlighting
let g:python_highlight_all = 1

" dense-analysis/ale
"" ALE fixers
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autoflake', 'black','isort']}
let g:ale_python_black_use_global = 1
let g:ale_python_isort_use_global = 1
let g:ale_python_isort_options = '--float-to-top --profile black'
"" ALE linters
let g:ale_linters_explicit = 1
let g:ale_linters = {'python': ['flake8', 'pyright']}
""" W503 is not PEP 8 compliant and black disregards it
let g:ale_python_flake8_options="--ignore E501,W503"
let g:ale_pattern_options = {
\   'ipython_log.py': {'ale_enabled': 0, 'ale_fixers': []},
\   'site-packages': {'ale_enabled': 0, 'ale_fixers': []},
\   'repos': {'ale_enabled': 0, 'ale_fixers': []},
\   }

"" ALE appearance
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
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

" hack to go to fully qualified names in strings ( like in settings.py )
" TODO: create a function that uses jedi#goto_definition and falls back to using this if it fails
" so that we use only one shortcut
noremap ga yi":Pyimport <C-R>+<CR>

" golang
let g:go_debug=['shell-commands']
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>d <Plug>(go-def)
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

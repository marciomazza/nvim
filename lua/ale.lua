-- ALE fixers
vim.g.ale_fix_on_save = 1
vim.g.ale_fixers = { ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
                     python = {'autoflake', 'black', 'isort'}}
vim.g.ale_python_black_use_global = 1
vim.g.ale_python_isort_use_global = 1
vim.g.ale_python_isort_options = '--float-to-top --profile black'

-- ALE linters
vim.g.ale_linters_explicit = 1
vim.g.ale_linters = {python = {'flake8', 'pyright'}}
-- W503 is not PEP 8 compliant and black disregards it
vim.g.ale_python_flake8_options="--ignore E501,W503"
vim.g.ale_pattern_options = {
  ['ipython_log.py'] = {ale_enabled = 0, ale_fixers = {}},
  ['site-packages'] = {ale_enabled = 0, ale_fixers = {}},
  repos = {ale_enabled = 0, ale_fixers = {}},
}

-- ALE appearance
vim.g.ale_echo_msg_error_str = 'E'
vim.g.ale_echo_msg_warning_str = 'W'
vim.g.ale_echo_msg_format = '[%linter%] %s [%severity%]'
vim.g.ale_virtualtext_cursor = 1
vim.g.ale_virtualtext_prefix = ' ▶  '
vim.g.ale_sign_error = '▶'
vim.g.ale_sign_warning = '▶'
vim.g.ale_sign_info = '▶'

-- ALE mappings
set_keymap('n', '<C-k>', '<Plug>(ale_previous_wrap)')
set_keymap('n', '<C-j>', '<Plug>(ale_next_wrap)')
set_keymap('n', '<C-l>', '<Plug>(ale_detail)')

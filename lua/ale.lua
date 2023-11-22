vim.cmd(
    [[
function! FormatLua(buffer) abort
    return {'command': 'luafmt --stdin'}
endfunction

function! FormatDjlint(buffer) abort
    return {'command': 'djlint --reformat -'}
endfunction

execute ale#fix#registry#Add('luafmt', 'FormatLua', ['lua'], 'luafmt for lua')
execute ale#fix#registry#Add('djlint', 'FormatDjlint', ['html'], 'djlint for html')
execute ale#fix#registry#Add('djlint', 'FormatDjlint', ['htmldjango'], 'djlint for htmldjango')

]]
)

-- turn off all linters by default
vim.g.ale_linters_explicit = 1

-- ALE fixers
vim.g.ale_fix_on_save = 1
vim.g.ale_fixers = {
    ["*"] = {"remove_trailing_lines", "trim_whitespace"},
    python = {"autoflake", "black", "isort"},
    lua = {"luafmt"},
    html = {"djlint"},
    htmldjango = {"djlint"}
}
vim.g.ale_python_black_use_global = 1
vim.g.ale_python_isort_use_global = 1
vim.g.ale_python_isort_options = "--float-to-top --profile black"

local disabled = {ale_enabled = 0, ale_fixers = {}}

vim.g.ale_pattern_options = {
    ["ipython_log.py"] = disabled,
    ["site-packages"] = disabled,
    ["plone"] = disabled,
    ["repos"] = disabled
}

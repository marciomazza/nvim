vim.cmd(
  [[
function! FormatDjlint(buffer) abort
    return {'command': 'djlint --reformat -'}
endfunction

execute ale#fix#registry#Add('djlint', 'FormatDjlint', ['html'], 'djlint for html')
execute ale#fix#registry#Add('djlint', 'FormatDjlint', ['htmldjango'], 'djlint for htmldjango')

]]
)

-- turn off all linters by default
vim.g.ale_linters_explicit = 1

-- ALE fixers
vim.g.ale_fix_on_save = 1
vim.g.ale_fixers = {
  ["*"] = { "remove_trailing_lines", "trim_whitespace" },
  html = { "djlint" },
  htmldjango = { "djlint" }
}

local disabled = { ale_enabled = 0, ale_fixers = {} }

vim.g.ale_pattern_options = {
  ["repos"] = disabled
}

-- TODO
-- for andymass/vim-matchup to work with django template tags
-- should work simply by using tweekmonster/django-plus.vim
-- based on
-- https://github.com/andymass/vim-matchup/issues/240
-- https://github.com/tweekmonster/django-plus.vim/blob/master/after/ftplugin/htmldjango.vim#L16

-- Configure vim-matchup for Django templates
vim.b.match_ignorecase = 1
vim.b.match_skip = "s:Comment"
vim.b.match_words = "<:>,"
  .. "<\\@<=[ou]l\\>[^>]*\\%(>\\|$\\):<\\@<=li\\>:<\\@<=/[ou]l>,"
  .. "<\\@<=dl\\>[^>]*\\%(>\\|$\\):<\\@<=d[td]\\>:<\\@<=/dl>,"
  .. "<\\@<=\\([^/][^ \\t>]*\\)[^>]*\\%(>\\|$\\):<\\@<=/\\1>,"
  .. "{% *if .*%}:{% *else *%}:{% *endif *%},"
  .. "\\%({% *\\)\\@<=\\%(end\\)\\@!\\(\\i\\+\\) .*%}:\\%({% *\\)\\@<=end\\1 .*%}"

vim.b.minisurround_config = {
  custom_surroundings = {
    t = { input = require("utils.html_tags").surround_tag_input },
  },
}

-- enable navigate to lua files with "gf" command
-- https://www.reddit.com/r/neovim/comments/pl0p5v/comment/hc78cye/?utm_source=share&utm_medium=web2x&context=3
vim.opt_local.suffixesadd:prepend('.lua')
vim.opt_local.suffixesadd:prepend('init.lua')
vim.opt_local.path:prepend(vim.fn.stdpath('config')..'/lua')

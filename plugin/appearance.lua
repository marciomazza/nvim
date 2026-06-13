vim.pack.add({
  "https://github.com/HiPhish/rainbow-delimiters.nvim",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/EdenEast/nightfox.nvim",
})

vim.opt.number = true -- enable line numbers in the editor
vim.opt.showtabline = 2 -- always show the tab line, even if there's only one tab
vim.wo.colorcolumn = "100" -- set a visual column marker at the 100th character position
vim.o.scrolloff = 999 -- keep the cursor centered when scrolling
vim.o.signcolumn = "auto" -- only show the sign column when there are signs to be displayed
vim.opt.cursorline = true -- highlight the current line

vim.opt.termguicolors = true -- required for colorizer and true color support
require("colorizer").setup({ filetypes = { "*", "!markdown" } })
vim.cmd.colorscheme("dayfox")

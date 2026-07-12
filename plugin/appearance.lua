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

-- Ghostty's terminfo lacks the Cs/Cr cursor-color capability, so Neovim never
-- emits OSC 12 for the Cursor highlight; send it directly instead.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function() io.write("\27]12;#FF8C00\27\\") end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    io.write("\27]112\27\\") -- reset cursor color on quit
  end,
})

-- switch to bright red while mini.jump is active, back to orange when it stops
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniJumpStart",
  callback = function() io.write("\27]12;#FF0000\27\\") end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniJumpStop",
  callback = function() io.write("\27]12;#FF8C00\27\\") end,
})

vim.opt.number = true -- enable line numbers in the editor
vim.opt.showtabline = 2 -- always show the tab line, even if there's only one tab
vim.wo.colorcolumn = "100" -- set a visual column marker at the 100th character position
vim.o.scrolloff = 999 -- keep the cursor centered when scrolling
vim.o.signcolumn = "auto" -- only show the sign column when there are signs to be displayed
vim.opt.cursorline = true -- highlight the current line

return {
  "HiPhish/rainbow-delimiters.nvim",
  { "catgoose/nvim-colorizer.lua", event = "BufReadPre", opts = true },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}

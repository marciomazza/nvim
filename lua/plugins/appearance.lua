vim.opt.number = true -- enable line numbers in the editor
vim.opt.showtabline = 2 -- always show the tab line, even if there's only one tab
vim.wo.colorcolumn = "100" -- set a visual column marker at the 100th character position
vim.o.scrolloff = 999 -- keep the cursor centered when scrolling
vim.o.signcolumn = "auto" -- only show the sign column when there are signs to be displayed
vim.opt.cursorline = true -- highlight the current line

return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        colors = {
          palette = {
            fujiGray = "#9a978d",
          },
        },
      })
      vim.cmd.colorscheme("kanagawa-wave")
      -- clearer, especially with MeanderingProgrammer/render-markdown.nvim
      vim.api.nvim_set_hl(0, "DiffChange", { bg = "#d4a520", fg = "#333333", bold = true })
    end,
  },
  {
    "itchyny/lightline.vim",
    dependencies = { "mengelbrecht/lightline-bufferline" },
    config = function()
      -- itchyny/lightline.vim & mengelbrecht/lightline-bufferline
      vim.g.lightline = {
        colorscheme = "PaperColor",
        active = {
          left = {
            { "mode", "paste" },
            { "gitbranch", "readonly", "filename", "modified" },
          },
        },
        component_function = { gitbranch = "FugitiveHead" },
        tabline = { left = { { "buffers" } }, right = { {} } },
        component_expand = { buffers = "lightline#bufferline#buffers" },
        component_type = { buffers = "tabsel" },
      }
      vim.g["lightline#bufferline#modified"] = " ★"
      vim.g["lightline#bufferline#read_only"] = " "
    end,
  },
  "HiPhish/rainbow-delimiters.nvim",
  { "catgoose/nvim-colorizer.lua", event = "BufReadPre", opts = true },
}

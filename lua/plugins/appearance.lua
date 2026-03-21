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
    "kepano/flexoki-neovim",
    name = "flexoki",
    init = function()
      vim.cmd.colorscheme("flexoki-light")

      -- Better visibility for current tab in mini.tabline
      -- Fetching colors from standard highlight groups to keep it theme-aware
      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
      local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
      local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
      -- Using Function's foreground color for modified tabs to make them stand out
      local stand_out = vim.api.nvim_get_hl(0, { name = "Function" }).fg

      vim.api.nvim_set_hl(0, "MiniTablineCurrent", { bg = normal.bg, fg = normal.fg, bold = true })
      vim.api.nvim_set_hl(0, "MiniTablineVisible", { bg = cursorline.bg, fg = comment.fg })
      vim.api.nvim_set_hl(0, "MiniTablineHidden", { bg = cursorline.bg, fg = comment.fg })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", { bg = normal.bg, fg = stand_out, bold = true })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedVisible", { bg = cursorline.bg, fg = stand_out })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden", { bg = cursorline.bg, fg = stand_out })
      vim.api.nvim_set_hl(0, "MiniTablineFill", { bg = cursorline.bg })
    end,
  },
}

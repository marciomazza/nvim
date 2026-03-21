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
      local colors = {
        paper = "#FFFCF0",
        surface = "#F2F0E5",
        overlay = "#E6E4D9",
        muted = "#878580",
        darkest = "#100F0F",
        cyan = "#24837B",
        orange = "#BC5215",
      }

      vim.api.nvim_set_hl(0, "MiniTablineCurrent", { bg = colors.paper, fg = colors.darkest, bold = true })
      vim.api.nvim_set_hl(0, "MiniTablineVisible", { bg = colors.surface, fg = colors.muted })
      vim.api.nvim_set_hl(0, "MiniTablineHidden", { bg = colors.overlay, fg = colors.muted })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", { bg = colors.paper, fg = colors.orange, bold = true })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedVisible", { bg = colors.surface, fg = colors.orange })
      vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden", { bg = colors.overlay, fg = colors.orange })
      vim.api.nvim_set_hl(0, "MiniTablineFill", { bg = colors.surface })
    end,
  },
}

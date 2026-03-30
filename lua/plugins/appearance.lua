vim.opt.number = true -- enable line numbers in the editor
vim.opt.showtabline = 2 -- always show the tab line, even if there's only one tab
vim.wo.colorcolumn = "100" -- set a visual column marker at the 100th character position
vim.o.scrolloff = 999 -- keep the cursor centered when scrolling
vim.o.signcolumn = "auto" -- only show the sign column when there are signs to be displayed
vim.opt.cursorline = true -- highlight the current line

-- fixme: this seems to be tied to the current light theme
--
-- Better visibility for current tab in mini.tabline
-- Fetching colors from standard highlight groups to keep it theme-aware
local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
-- Using Function's foreground color for modified tabs to make them stand out
local stand_out = vim.api.nvim_get_hl(0, { name = "Function" }).fg

-- vim.api.nvim_set_hl(0, "MiniTablineCurrent", { bg = normal.bg, fg = normal.fg, bold = true })
-- vim.api.nvim_set_hl(0, "MiniTablineVisible", { bg = cursorline.bg, fg = comment.fg })
-- vim.api.nvim_set_hl(0, "MiniTablineHidden", { bg = cursorline.bg, fg = comment.fg })
-- vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", { bg = normal.bg, fg = stand_out, bold = true })
-- vim.api.nvim_set_hl(0, "MiniTablineModifiedVisible", { bg = cursorline.bg, fg = stand_out })
-- vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden", { bg = cursorline.bg, fg = stand_out })
-- vim.api.nvim_set_hl(0, "MiniTablineFill", { bg = cursorline.bg })

-- -- Neogit diff highlights for light theme
-- vim.api.nvim_set_hl(0, "NeogitDiffAdd", { bg = "#d4edda", fg = "#1a3a22" })
-- vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { bg = "#a8d5b5", fg = "#1a3a22" })
-- vim.api.nvim_set_hl(0, "NeogitDiffDelete", { bg = "#f8d7da", fg = "#3a1a1a" })
-- vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { bg = "#f1adb3", fg = "#3a1a1a" })
-- -- vim.api.nvim_set_hl(0, "NeogitDiffContext", { bg = "#f5f0e8" })
-- -- vim.api.nvim_set_hl(0, "NeogitDiffContextHighlight", { bg = "#ece6d8" })
-- vim.api.nvim_set_hl(0, "NeogitHunkHeader", { bg = "#ddd8cc", fg = "#4a4035", bold = true })
-- vim.api.nvim_set_hl(0, "NeogitHunkHeaderHighlight", { bg = "#ccc6b8", fg = "#2a2018", bold = true })

return {
  "HiPhish/rainbow-delimiters.nvim",
  { "catgoose/nvim-colorizer.lua", event = "BufReadPre", opts = true },
  {
    "kepano/flexoki-neovim",
    name = "flexoki",
  },
  {
    "EdenEast/nightfox.nvim",
    init = function()
      vim.cmd.colorscheme("dayfox")
    end,
  },
}

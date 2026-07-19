vim.pack.add({
  "https://github.com/HiPhish/rainbow-delimiters.nvim",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/EdenEast/nightfox.nvim",
  "https://github.com/kepano/flexoki-neovim",
  "https://github.com/yorik1984/newpaper.nvim",
  "https://github.com/projekt0n/github-nvim-theme",
  "https://github.com/navarasu/onedark.nvim",
  "https://github.com/scottmckendry/cyberdream.nvim",
  "https://github.com/olimorris/onedarkpro.nvim",
})

vim.opt.number = true -- enable line numbers in the editor
vim.opt.showtabline = 2 -- always show the tab line, even if there's only one tab
vim.wo.colorcolumn = "100" -- set a visual column marker at the 100th character position
vim.o.scrolloff = 999 -- keep the cursor centered when scrolling
vim.o.signcolumn = "auto" -- only show the sign column when there are signs to be displayed
vim.opt.cursorline = true -- highlight the current line
vim.o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

vim.opt.termguicolors = true -- required for colorizer and true color support
require("colorizer").setup({ filetypes = { "*", "!markdown" } })

local c = require("flexoki.palette").palette()
local blend = require("flexoki.util").blend
local groups = require("flexoki.highlights").groups()
groups.Comment.fg = c["tx-2"]
for _, hl in pairs(groups) do
  if hl.fg and hl.fg ~= "NONE" then hl.fg = blend(hl.fg, "#000000", 0.8) end
end

require("nightfox").setup({
  palettes = { dayfox = { bg1 = "#FFFCF0" } },
  groups = { dayfox = { TabLineSel = { bg = "#dbd1dd" } } },
})
require("newpaper").setup({})
local cyberdream_bg = "#FFFCF0"
local function shade(hex, factor)
  local r, g, b =
    tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  return string.format(
    "#%02X%02X%02X",
    math.floor(r * factor),
    math.floor(g * factor),
    math.floor(b * factor)
  )
end
local cyberdream_bg_highlight = shade(cyberdream_bg, 0.95)
local palette = require("cyberdream.colors").light
local cyberdream_fg = palette.fg
local cyberdream_grey = palette.grey
local cyberdream_red = palette.red
require("cyberdream").setup({
  colors = { bg = cyberdream_bg, bg_highlight = cyberdream_bg_highlight },

  highlights = {
    Visual = { bg = "#E8D5FF" },

    MiniStatuslineDevinfo = { bg = "#DAD8CE" },
    MiniStatuslineFilename = { bg = "#E6E4D9" },

    MiniStatuslineFileinfo = { bg = "#DAD8CE" },
    -- swap active/inactive tab colors: active tabs now light, inactive tabs dark
    MiniTablineCurrent = { fg = palette.orange, bg = "#F5EAA0", bold = true },
    MiniTablineVisible = { fg = cyberdream_grey, bg = cyberdream_bg },
    MiniTablineHidden = { fg = cyberdream_fg, bg = cyberdream_bg_highlight },
    MiniTablineFill = { bg = cyberdream_bg_highlight },

    MiniTablineModifiedCurrent = { fg = cyberdream_red, bg = cyberdream_bg, bold = true },
    MiniTablineModifiedVisible = { fg = cyberdream_red, bg = cyberdream_bg },
    MiniTablineModifiedHidden = { fg = cyberdream_red, bg = cyberdream_bg_highlight },
  },
})
require("onedark").setup({})
vim.cmd.colorscheme("cyberdream-light")
for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
  if hl.fg then
    hl.fg = bit.bor(
      bit.lshift(math.floor(bit.band(bit.rshift(hl.fg, 16), 0xFF) * 0.8), 16),
      bit.lshift(math.floor(bit.band(bit.rshift(hl.fg, 8), 0xFF) * 0.8), 8),
      math.floor(bit.band(hl.fg, 0xFF) * 0.8)
    )
    vim.api.nvim_set_hl(0, name, hl)
  end
end

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

-- black bar for insert mode; normal mode keeps the orange block
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:n",
  callback = function() io.write("\27]12;#FF8C00\27\\") end,
})
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:i",
  callback = function() io.write("\27]12;#FF0000\27\\") end,
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

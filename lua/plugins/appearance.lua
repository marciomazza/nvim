vim.opt.number = true      -- enable line numbers in the editor
vim.opt.showtabline = 2    -- always show the tab line, even if there's only one tab
vim.wo.colorcolumn = "100" -- set a visual column marker at the 100th character position
vim.o.scrolloff = 999      -- keep the cursor centered when scrolling

local function noice_skip(pattern)
  return {
    filter = { event = "msg_show", find = pattern },
    opts = { skip = true },
  }
end

return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup({
        colors = {
          palette = {
            fujiGray = "#9a978d",
          },
        }
      })
      vim.cmd.colorscheme('kanagawa-wave')
    end,
  },
  {
    "itchyny/lightline.vim",
    dependencies = { "mengelbrecht/lightline-bufferline" },
    config = function()
      -- itchyny/lightline.vim & mengelbrecht/lightline-bufferline
      vim.g.lightline = {
        colorscheme = "kanagawa-wave",
        active = {
          left = {
            { "mode",      "paste" },
            { "gitbranch", "readonly", "filename", "modified" }
          }
        },
        component_function = { gitbranch = "FugitiveHead" },
        tabline = { left = { { "buffers" } }, right = { {} } },
        component_expand = { buffers = "lightline#bufferline#buffers" },
        component_type = { buffers = "tabsel" }
      }
      vim.g["lightline#bufferline#modified"] = " ★"
      vim.g["lightline#bufferline#read_only"] = " "
    end
  },
  "folke/lsp-colors.nvim",
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    config = true,
    opts = {
      routes = {
        noice_skip(" written$"), -- don't show saved file message
        noice_skip("^search hit BOTTOM, continuing at TOP$"),
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  }
}

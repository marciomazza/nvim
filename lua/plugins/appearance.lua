vim.opt.number = true
vim.opt.relativenumber = true
-- It breaks a lot of things, so suspended. Perhaps use it in the future
-- vim.opt.cmdheight = 0  -- autohide the command-line (https://vi.stackexchange.com/a/38231)
vim.opt.showtabline = 2
vim.wo.colorcolumn = "100"

local function noice_skip(pattern)
  return {
    filter = { event = "msg_show", find = pattern },
    opts = { skip = true },
  }
end

return {
  {
    "NLKNguyen/papercolor-theme",
    config = function()
      vim.cmd.colorscheme "PaperColor"
    end
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

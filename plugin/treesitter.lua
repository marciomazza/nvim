pack_changed_hook("nvim-treesitter", function(ev) vim.cmd("TSUpdate") end)

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/MeanderingProgrammer/treesitter-modules.nvim",
})

require("treesitter-context").setup({ max_lines = 1 })

---@module 'treesitter-modules'
---@type ts.mod.UserConfig
require("treesitter-modules").setup({
  ensure_installed = { "python", "lua", "rust", "javascript", "sql" },
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(_, _)
      -- disable treesitter for buffers that are too big (it's too slow)
      local buffer_size = vim.fn.line2byte(vim.fn.line("$") + 1) - 1
      return buffer_size > 300 * 1024 -- 300KB
    end,
  },
  matchup = { enable = true }, -- enable andymass/vim-matchup
  -- autotag = { enable = true }, -- enable windwp/nvim-ts-autotag
  indent = { enable = true },
  -- textobjects = { select = { enable = true } },
})

local ts_select = require("vim.treesitter._select")
vim.keymap.set(
  { "n", "x" },
  "<M-Up>",
  function() ts_select.select_parent(vim.v.count1) end,
  { desc = "Expand selection" }
)
vim.keymap.set(
  "x",
  "<M-Down>",
  function() ts_select.select_child(vim.v.count1) end,
  { desc = "Shrink selection" }
)

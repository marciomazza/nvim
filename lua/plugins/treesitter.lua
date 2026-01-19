return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
  },
  "nvim-treesitter/nvim-treesitter-textobjects",
  {
    -- fixme: didn't really solve my issue:
    -- it's showing just the method context and I wanted the class or both
    "nvim-treesitter/nvim-treesitter-context",
    opts = { max_lines = 1 },
  },
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ---@module 'treesitter-modules'
    ---@type ts.mod.UserConfig
    opts = {
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
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<M-Up>",
          node_incremental = "<M-Up>",
          node_decremental = "<M-Down>",
        },
      },
    },
    textobjects = { select = { enable = true } },
  },
}

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/playground",
  },
  config = function()
    require "nvim-treesitter.configs".setup {
      ensure_installed = { "python", "lua", "rust", "javascript", "sql" },
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(_, _)
          -- disable treesitter for buffers that are too big (it's too slow)
          local buffer_size = vim.fn.line2byte(vim.fn.line("$") + 1) - 1
          return buffer_size > 300 * 1024 -- 300KB
        end
      },
      matchup = { enable = true }, -- enable andymass/vim-matchup
      indent = { enable = true },
      incremental_selection = { enable = true,
        keymaps = {
          init_selection = "<M-Up>",
          node_incremental = "<M-Up>",
          node_decremental = "<M-Down>",
        },
      },
      playground = {
        enable = true,
        disable = {},
        updatetime = 25,        -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false -- Whether the query persists across vim sessions
      },
    }
  end
}

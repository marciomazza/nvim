return {
  "lewis6991/gitsigns.nvim",
  {
    "andymass/vim-matchup",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  { "windwp/nvim-ts-autotag", config = true },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "stevearc/aerial.nvim",
    opts = {
      layout = {
        min_width = 20,
        max_width = { 30, 0.3 },
      },
      focus_on_open = true,
      close_on_select = true,
      close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
      autojump = true,
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<F4>",
        function()
          require("aerial").toggle()
        end,
        desc = "Toggle Aerial",
      },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    config = function()
      local keys_to_actions = {
        rf = "Extract Function",
        rv = "Extract Variable",
        rI = "Inline Function",
        ri = "Inline Variable",
      }
      for keys, action in pairs(keys_to_actions) do
        local refactor = function()
          return require("refactoring").refactor(action)
        end
        vim.keymap.set({ "n", "x" }, "<leader>" .. keys, refactor, { expr = true, desc = action })
      end
    end,
  },

  -- django
  "tweekmonster/django-plus.vim",

  -- testing
  { "andythigpen/nvim-coverage", dependencies = { "nvim-lua/plenary.nvim" }, opts = { auto_reload = true } },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
    },
    opts = function()
      return { adapters = { require("neotest-python") } }
    end,
  },

  -- lua + neovim
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}

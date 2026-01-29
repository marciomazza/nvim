-- todo: choose copilot x windosurf x something else

return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
      }

      vim.o.autoread = true

      -- Prefixo <leader>o para opencode
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode" })
      vim.keymap.set({ "n", "x" }, "<leader>ox", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<leader>oo", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      -- Operador: gp (p = put to opencode)
      vim.keymap.set({ "n", "x" }, "gp", function()
        return require("opencode").operator("@this ")
      end, { expr = true, desc = "Add range to opencode" })
      vim.keymap.set("n", "gpp", function()
        return require("opencode").operator("@this ") .. "_"
      end, { expr = true, desc = "Add line to opencode" })

      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "opencode half page up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "opencode half page down" })
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    opts = {
      -- disable_inline_completion = true,
    },
  },
}

-- return {
--   {
--     "Exafunction/windsurf.nvim",
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "saghen/blink.cmp",
--     },
--     config = function()
--       require("codeium").setup({
--         enable_cmp_source = false,
--         -- virtual_text = { enabled = true },
--       })
--     end,
--   },
-- }

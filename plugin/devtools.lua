vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/andymass/vim-matchup",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/stevearc/aerial.nvim",
  "https://github.com/tweekmonster/django-plus.vim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/esmuellert/codediff.nvim",
  "https://github.com/nicolasgb/jj.nvim",
})

require("gitsigns").setup()
vim.g.matchup_matchparen_offscreen = { method = "popup" }
require("nvim-ts-autotag").setup()
require("nvim-autopairs").setup()

require("aerial").setup({
  layout = {
    min_width = 20,
    max_width = { 30, 0.3 },
  },
  focus_on_open = true,
  close_on_select = true,
  close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
  autojump = true,
})
vim.keymap.set("n", "<F4>", function() require("aerial").toggle() end, { desc = "Toggle Aerial" })

require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

local jj_log_current = "jj log -r @ --no-graph"

-- Both backends leave the diff panes at 50/50; widen the right side by 40 columns.
-- Native sets the 'diff' window option; codediff doesn't, so fall back to its own API.
local function widen_right_diff_pane()
  vim.schedule(function()
    local wins = vim.tbl_filter(
      function(w) return vim.wo[w].diff end,
      vim.api.nvim_tabpage_list_wins(0)
    )
    if #wins ~= 2 then
      local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
      local left, right = ok and lifecycle.get_windows(vim.api.nvim_get_current_tabpage())
      if not (left and right) then return end
      wins = { left, right }
    end
    table.sort(
      wins,
      function(a, b)
        return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
      end
    )
    local total = vim.api.nvim_win_get_width(wins[1]) + vim.api.nvim_win_get_width(wins[2])
    vim.api.nvim_win_set_width(wins[2], math.floor(total / 2) + 40)
    vim.api.nvim_set_current_win(wins[2])
  end)
end

local function jj_diff()
  local is_empty = vim.fn.system(jj_log_current .. " -T 'empty'"):match("true")
  require("jj.diff").open_vdiff(is_empty and { rev = "@--" } or nil)
  widen_right_diff_pane()
end

local function setup_and_jj_diff()
  -- lazy setup
  require("codediff").setup({ diff = { compute_moves = true } })
  require("jj").setup({
    diff = {
      backend = vim.fn.system(jj_log_current):match("default@") and "codediff" or "native",
    },
  })
  -- update the keymap for the next calls
  vim.keymap.set("n", "<leader>d", jj_diff, { desc = "JJ diff current buffer" })
  jj_diff()
end
vim.keymap.set("n", "<leader>d", setup_and_jj_diff, { desc = "JJ diff current buffer" })

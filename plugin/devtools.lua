vim.pack.add({
  "https://github.com/andymass/vim-matchup",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/stevearc/aerial.nvim",
  "https://github.com/tweekmonster/django-plus.vim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/nicolasgb/jj.nvim",
})

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

-- jj strips JJ: lines anyway; just declutter the editor
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.jjdescription",
  callback = function()
    vim.cmd([[silent! keeppatterns g/^JJ: Enter a description for the combined commit\.$/d]])
    vim.cmd([[silent! keeppatterns g/^JJ: Description from the destination commit:$/d]])
  end,
})

local jj_log_current = "jj log -r @ --no-graph"

local function jj_diff()
  local is_empty = vim.fn.system(jj_log_current .. " -T 'empty'"):match("true")
  require("jj.diff").open_vdiff(is_empty and { rev = "@--" } or nil)
end

local function setup_and_jj_diff()
  -- lazy setup; native backend respects global 'wrap', unlike codediff
  require("jj").setup({ diff = { backend = "native" } })
  -- update the keymap for the next calls
  vim.keymap.set("n", "<leader>d", jj_diff, { desc = "JJ diff current buffer" })
  jj_diff()
end
vim.keymap.set("n", "<leader>d", setup_and_jj_diff, { desc = "JJ diff current buffer" })

-- jj.nvim's native diff backend restores the cursor to where it was BEFORE the diff
-- opened, not where it ended up. Re-apply the correct position after its own
-- restore (which fires on the next tick, deferred by 10ms) has already run.
vim.api.nvim_create_autocmd({ "BufWipeout", "BufHidden" }, {
  pattern = "jj://*",
  callback = function(ev)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) ~= ev.buf then
        local pos = vim.api.nvim_win_get_cursor(win)
        vim.defer_fn(function()
          if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_set_cursor, win, pos)
          end
        end, 50)
        break
      end
    end
  end,
})

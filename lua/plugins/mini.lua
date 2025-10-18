local function setup_mini_files()
  local MiniFiles = require("mini.files")
  local file_explorer_ignored = { ".*\\.pyc", "__pycache__" }

  local function minifiles_toggle()
    if not MiniFiles.close() then
      MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end
  end

  MiniFiles.setup({
    mappings = { go_in_plus = "<Enter>", go_out_plus = "<Esc>" },
    windows = {
      preview = true,
      width_focus = 20,
      width_preview = 80,
    },
    content = {
      filter = function(fs_entry)
        if vim.startswith(fs_entry.name, ".") then
          return false
        end
        for _, pattern in ipairs(file_explorer_ignored) do
          if vim.fn.match(fs_entry.name, pattern) >= 0 then
            return false
          end
        end
        return true
      end,
    },
  })
  vim.keymap.set("n", "<F3>", minifiles_toggle, { desc = "Toggle file explorer" })
end

local function setup_mini_comment()
  local custom_comment_patterns = {
    sql = "-- %s",
    htmldjango = "{# %s #}",
  }
  require("mini.comment").setup({
    options = {
      custom_commentstring = function()
        return custom_comment_patterns[vim.bo.filetype]
      end,
    },
  })
end

local function setup_mini_hipatterns()
  -- switch TODO and HACK highlighters
  local function get_hl(name)
    local data = vim.api.nvim_get_hl(0, { name = name, link = false })
    return { bg = data.bg, fg = data.fg, bold = data.bold }
  end
  local todo_data, hack_data = get_hl("MiniHipatternsTodo"), get_hl("MiniHipatternsHack")
  vim.api.nvim_set_hl(0, "MiniHipatternsTodo", hack_data)
  vim.api.nvim_set_hl(0, "MiniHipatternsHack", todo_data)

  local words_highlighter = require("mini.extra").gen_highlighter.words
  require("mini.hipatterns").setup({
    highlighters = {
      todo = words_highlighter({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
      fixme = words_highlighter({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
      xxx = words_highlighter({ "XXX", "xxx" }, "MiniHipatternsHack"),
    },
  })
end

local function setup_mini_pick()
  local MiniPick = require("mini.pick")
  MiniPick.setup()
  vim.ui.select = MiniPick.ui_select
  vim.keymap.set("n", "<leader>f", function()
    MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
  end, { desc = "Find word" })
  vim.keymap.set("n", "<leader>F", MiniPick.builtin.grep_live, { desc = "Live grep" })
  vim.keymap.set("n", "<leader>e", MiniPick.builtin.files, { desc = "Pick file" })
end

local function setup_mini_clue()
  local MiniClue = require("mini.clue")
  local triggers = {
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
  }
  for _, key in ipairs({ "<Leader>", "g", "<C-w>", "z" }) do
    table.insert(triggers, { mode = "n", keys = key })
    table.insert(triggers, { mode = "x", keys = key })
  end
  MiniClue.setup({
    triggers = triggers,
    clues = {
      MiniClue.gen_clues.square_brackets(),
      MiniClue.gen_clues.g(),
      MiniClue.gen_clues.windows(),
      MiniClue.gen_clues.z(),
      -- descriptions for groups
      {
        { mode = "n", keys = "<Leader>r", desc = "+Refactor" },
        { mode = "x", keys = "<Leader>r", desc = "+Refactor" },
      },
    },
    window = { delay = 300 },
  })
end

local function setup_mini_surround()
  local ts_input = require("mini.surround").gen_spec.input.treesitter
  require("mini.surround").setup({
    custom_surroundings = {
      f = { input = ts_input({ outer = "@call.outer", inner = "@call.inner" }) },
      t = { input = ts_input({ outer = "@function.outer", inner = "@function.inner" }) },
    },
  })
end

return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.ai").setup()
    require("mini.align").setup()
    require("mini.operators").setup({ replace = { prefix = "rr" } })
    require("mini.pairs").setup()
    setup_mini_surround()
    require("mini.jump").setup()
    require("mini.splitjoin").setup()
    require("mini.extra").setup()
    require("mini.icons").setup()
    require("mini.cursorword").setup()
    local MiniGit = require("mini.git")
    MiniGit.setup()
    vim.keymap.set({ "n", "x" }, "<Leader>gs", MiniGit.show_at_cursor, { desc = "Show at cursor" })
    require("mini.diff").setup()
    require("mini.statusline").setup()
    require("mini.tabline").setup()
    setup_mini_files()
    setup_mini_comment()
    setup_mini_hipatterns()
    setup_mini_pick()
    setup_mini_clue()
  end,
}

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

local function setup(mini_module, opts)
  local module = require(mini_module)
  module.setup(opts or {})
  return module
end

------------------------------------------------------------------------------------------
--- editing
------------------------------------------------------------------------------------------
setup("mini.align")
setup("mini.operators", { replace = { prefix = "rr" } })
setup("mini.pairs")
setup("mini.surround")
setup("mini.jump")
setup("mini.splitjoin")
MiniAi = setup("mini.ai")

-- specific for html / htmldjango
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "htmldjango" },
  callback = function(args)
    vim.b[args.buf].miniai_config = {
      custom_textobjects = {
        a = MiniAi.gen_spec.treesitter({ a = "@attribute.outer", i = "@attribute.inner" }),
      },
    }
    vim.b[args.buf].minisurround_config = {
      custom_surroundings = {
        t = { input = require("utils.html_tags").surround_tag_input },
      },
    }
  end,
})

------------------------------------------------------------------------------------------
--- visual
------------------------------------------------------------------------------------------
setup("mini.cursorword")
setup("mini.statusline")
setup("mini.tabline")

------------------------------------------------------------------------------------------
--- mini.files
------------------------------------------------------------------------------------------
local file_explorer_ignored = { ".*\\.pyc", "__pycache__", "ipython_log\\.py.*" }

local MiniFiles = setup("mini.files", {
  mappings = { go_in_plus = "<Enter>", go_out_plus = "<Esc>" },
  windows = {
    preview = true,
    width_focus = 30,
    width_preview = 80,
  },
  content = {
    filter = function(fs_entry)
      if vim.startswith(fs_entry.name, ".") then return false end
      for _, pattern in ipairs(file_explorer_ignored) do
        if vim.fn.match(fs_entry.name, pattern) >= 0 then return false end
      end
      return true
    end,
  },
})

local function minifiles_toggle()
  if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0)) end
end

vim.keymap.set("n", "<F3>", minifiles_toggle, { desc = "Toggle file explorer" })

------------------------------------------------------------------------------------------
--- mini.comment
------------------------------------------------------------------------------------------
local custom_comment_patterns = {
  sql = "-- %s",
  htmldjango = "{# %s #}",
  kitty = "# %s",
}
setup("mini.comment", {
  options = {
    custom_commentstring = function() return custom_comment_patterns[vim.bo.filetype] end,
  },
})

------------------------------------------------------------------------------------------
--- mini.hipatterns
------------------------------------------------------------------------------------------
-- switch TODO and HACK highlighters
local function get_hl(name)
  local data = vim.api.nvim_get_hl(0, { name = name, link = false })
  return { bg = data.bg, fg = data.fg, bold = data.bold }
end
local todo_data, hack_data = get_hl("MiniHipatternsTodo"), get_hl("MiniHipatternsHack")
vim.api.nvim_set_hl(0, "MiniHipatternsTodo", hack_data)
vim.api.nvim_set_hl(0, "MiniHipatternsHack", todo_data)

local words_highlighter = setup("mini.extra").gen_highlighter.words
setup("mini.hipatterns", {
  highlighters = {
    todo = words_highlighter({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
    fixme = words_highlighter({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
    xxx = words_highlighter({ "XXX", "xxx" }, "MiniHipatternsHack"),
    temp = words_highlighter({ "TEMP", "temp" }, "MiniHipatternsHack"),
  },
})

------------------------------------------------------------------------------------------
--- mini.clue
------------------------------------------------------------------------------------------
local MiniClue = setup("mini.clue")
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

------------------------------------------------------------------------------------------
--- misc & icons
------------------------------------------------------------------------------------------
local MiniMisc = setup("mini.misc")
local later = function(f) MiniMisc.safely("later", f) end

local MiniIcons = setup("mini.icons")
later(MiniIcons.tweak_lsp_kind)

------------------------------------------------------------------------------------------
--- completion & snippets
------------------------------------------------------------------------------------------
setup("mini.completion")
-- disable completion in fff's input buffer to avoid conflict with the picker
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fff_input",
  callback = function() vim.b.minicompletion_disable = true end,
})
local gen_loader = require("mini.snippets").gen_loader
setup("mini.snippets", { snippets = { gen_loader.from_lang() } })

local MiniKeymap = setup("mini.keymap")
-- NOTE: this will never insert tab, press <C-v><Tab> for that
local tab_steps = {
  "minisnippets_next",
  "minisnippets_expand",
  "pmenu_next",
  "jump_after_tsnode",
  "jump_after_close",
}
MiniKeymap.map_multistep("i", "<Tab>", tab_steps)
local shifttab_steps =
  { "minisnippets_prev", "pmenu_prev", "jump_before_tsnode", "jump_before_open" }
MiniKeymap.map_multistep("i", "<S-Tab>", shifttab_steps)

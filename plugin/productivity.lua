vim.pack.add({
  "https://github.com/bngarren/checkmate.nvim",
})

require("checkmate").setup({
  todo_states = {
    unchecked = { marker = "□" },
    checked = { marker = "✓" },
    in_progress = {
      marker = "▶",
      markdown = ".",
      type = "incomplete",
      order = 50,
    },
    cancelled = {
      marker = "✗",
      markdown = "c",
      type = "complete",
      order = 2,
    },
  },
  metadata = {
    -- Example: A @priority tag that has dynamic color based on the priority value
    priority = {
      style = function(context)
        local value = context.value:lower()
        if value == "urgent" then
          return { fg = "#c62828", bold = true }
        elseif value == "high" then
          return { fg = "#e65100", bold = true }
        elseif value == "normal" then
          return { fg = "#2e7d32" }
        elseif value == "low" then
          return { fg = "#1565c0" }
        else -- fallback
          return { fg = "#1565c0" }
        end
      end,
      get_value = function()
        return "high" -- Default priority when set (actual default is normal)
      end,
      choices = function() return { "low", "normal", "high", "urgent" } end,
      key = "<leader>Tp",
      sort_order = 10,
      jump_to_on_insert = "value",
      select_on_insert = true,
    },
  },
  style = {
    CheckmateUncheckedAdditionalContent = { bg = "#ebebeb" },
  },
})

vim.api.nvim_set_hl(0, "Folded", { link = "Normal" })
vim.api.nvim_set_hl(0, "CheckmateMeta_started", { fg = "#1565c0" })
vim.api.nvim_set_hl(0, "CheckmateMeta_done", { fg = "#1b7a1b" })
vim.api.nvim_set_hl(0, "CheckmateCheckedMarker", { bold = true })
local color_progress = "#cc7a00"
vim.api.nvim_set_hl(0, "CheckmateInProgressMarker", { fg = color_progress })
vim.api.nvim_set_hl(0, "CheckmateInProgressMainContent", { fg = color_progress })

-----------------------------------------------------------------------------------
--- FOLD
-----------------------------------------------------------------------------------
local todo_marker = "^%- [%[□✓▶✗]"
local indented = "^  "

local function next_nonempty_line(lnum)
  local last = vim.fn.line("$")
  local n = lnum + 1
  while n <= last and vim.fn.getline(n) == "" do
    n = n + 1
  end
  return vim.fn.getline(n)
end

local function todo_foldexpr(lnum)
  local line = vim.fn.getline(lnum)
  if line:match(todo_marker) then
    return next_nonempty_line(lnum):match(indented) and ">1" or "0"
  end
  if line:match(indented) then return "1" end
  if line == "" then
    local prev = vim.fn.getline(lnum - 1)
    if prev:match(indented) then return "1" end
    if prev:match(todo_marker) and next_nonempty_line(lnum):match(indented) then return "1" end
  end
  return "0"
end
_G._todo_foldexpr = todo_foldexpr

local function todo_foldtext() return vim.fn.getline(vim.v.foldstart) end
_G._todo_foldtext = todo_foldtext

-----------------------------------------------------------------------------------
--- special setup for the file type
-----------------------------------------------------------------------------------

-- Remap all default <leader>T... keymaps to <leader>t... .
-- checkmate registers its FileType autocmd inside setup(); registering ours
-- afterwards guarantees ours fires second, after checkmate's keymaps are set.
-- This covers both action keys and metadata keys in one loop.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    if not require("checkmate.buffer").is_active(ev.buf) then return end
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua._todo_foldexpr(v:lnum)"
    vim.opt_local.foldtext = "v:lua._todo_foldtext()"
    vim.opt_local.foldlevel = 99
    local leader = vim.api.nvim_replace_termcodes("<leader>", true, false, true)
    local prefix = leader .. "T"
    for _, mode in ipairs({ "n", "v" }) do
      for _, map in ipairs(vim.api.nvim_buf_get_keymap(ev.buf, mode)) do
        if map.lhs:sub(1, #prefix) == prefix then
          local suffix = map.lhs:sub(#prefix + 1)
          local rhs = map.callback or map.rhs
          if rhs then
            pcall(vim.api.nvim_buf_del_keymap, ev.buf, mode, map.lhs)
            vim.keymap.set(mode, "<leader>t" .. suffix, rhs, {
              buffer = ev.buf,
              desc = map.desc,
              silent = map.silent == 1,
            })
          end
        end
      end
    end
    local rs = require("utils.redmine_sync")
    vim.keymap.set(
      "n",
      "<leader>tP",
      rs.populate_todo,
      { buffer = ev.buf, desc = "Populate all todo's from Redmine", silent = true }
    )
    vim.keymap.set(
      "n",
      "<leader>tU",
      rs.update_issue_under_cursor,
      { buffer = ev.buf, desc = "Update Redmine issue under cursor", silent = true }
    )
    vim.keymap.set(
      "n",
      "<leader>tC",
      rs.create_or_update_all,
      { buffer = ev.buf, desc = "Create/update all Redmine issues", silent = true }
    )
    vim.keymap.set("n", "go", function()
      if vim.api.nvim_get_current_line():match("@issue%(%#%d+%)") then
        local _, err = require("utils.redmine_sync").open_issue_under_cursor()
        if err then vim.notify(err, vim.log.levels.WARN) end
      else
        require("utils").open_url()
      end
    end, { buffer = ev.buf, desc = "Open Redmine issue or URL under cursor" })
  end,
})

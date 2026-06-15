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
        if value == "high" then
          return { fg = "#ff5555", bold = true }
        elseif value == "medium" then
          return { fg = "#ffb86c" }
        elseif value == "low" then
          return { fg = "#8be9fd" }
        else -- fallback
          return { fg = "#8be9fd" }
        end
      end,
      get_value = function()
        return "medium" -- Default priority
      end,
      choices = function() return { "low", "medium", "high" } end,
    },
  },
})

vim.api.nvim_set_hl(0, "CheckmateMeta_started", { fg = "#1565c0" })
vim.api.nvim_set_hl(0, "CheckmateMeta_done", { fg = "#1b7a1b" })
vim.api.nvim_set_hl(0, "CheckmateCheckedMarker", { bold = true })
local color_progress = "#cc7a00"
vim.api.nvim_set_hl(0, "CheckmateInProgressMarker", { fg = color_progress })
vim.api.nvim_set_hl(0, "CheckmateInProgressMainContent", { fg = color_progress })

-- Remap all default <leader>T... keymaps to <leader>t... .
-- checkmate registers its FileType autocmd inside setup(); registering ours
-- afterwards guarantees ours fires second, after checkmate's keymaps are set.
-- This covers both action keys and metadata keys in one loop.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
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
    vim.keymap.set("n", "go", function()
      if vim.api.nvim_get_current_line():match("@issue%(%#%d+%)") then
        local _, err = require("utils.redmine_sync").open_issue_under_cursor()
        if err then
          vim.notify(err, vim.log.levels.WARN)
        end
      else
        require("utils").open_url()
      end
    end, { buffer = ev.buf, desc = "Open Redmine issue or URL under cursor", silent = true })
  end,
})

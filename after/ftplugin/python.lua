vim.opt_local.formatoptions = "croqj"

local function insert_breakpoint()
  -- inserts 'breakpoint()' in the line above the cursor with the same indentation
  local bufnr = 0 -- Buffer atual
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]
  local indent = line:match("^%s*") or ""
  vim.api.nvim_buf_set_lines(bufnr, line_num - 1, line_num - 1, false, { indent .. "breakpoint()" })
end

vim.keymap.set("n", "<leader>b", insert_breakpoint, { noremap = true, silent = true })

vim.opt_local.formatoptions = "croqj"

local function insert_breakpoint()
  local cursor_pos = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match("^%s*")
  vim.api.nvim_buf_set_lines(0, cursor_pos, cursor_pos, false, { indent .. "breakpoint()" })
end

vim.keymap.set("n", "<leader>b", insert_breakpoint, { noremap = true, silent = true })

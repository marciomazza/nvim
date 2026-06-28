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

-------------------------------------------------------------------------------
--- javascript injection highlights
-------------------------------------------------------------------------------

-- Visually distinguish Python strings that contain injected JavaScript
-- (see after/queries/python/injections.scm for which patterns qualify).
-- highlights.scm priority tricks don't reliably override injection subtree
-- highlights, so we apply extmarks directly at priority 200, which layers
-- bg+italic on top of the per-token JS colors from the injection.

local JS_NS = vim.api.nvim_create_namespace("python_js_embedded")

-- Blend 20% of the target tint into the theme's Normal bg so the color
-- adapts when the colorscheme changes.
local function set_js_hl()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local base = normal.bg or 0xf6f2ee
  local cyan = 0x90d0d8
  local function ch(c, s) return bit.band(bit.rshift(c, s), 0xff) end
  local bg = math.floor(ch(base, 16) * 0.8 + ch(cyan, 16) * 0.2) * 0x10000
    + math.floor(ch(base, 8) * 0.8 + ch(cyan, 8) * 0.2) * 0x100
    + math.floor(ch(base, 0) * 0.8 + ch(cyan, 0) * 0.2)
  vim.api.nvim_set_hl(0, "@python.js_embedded", { italic = true, bg = bg })
end
set_js_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_js_hl })

-- Reuse the patterns from injections.scm (single source of truth).
-- Strip injection-only directives so the query can be used for highlights.
local function load_js_query()
  local path = vim.fn.stdpath("config") .. "/after/queries/python/injections.scm"
  local src = table
    .concat(vim.fn.readfile(path), "\n")
    :gsub("@injection%.content", "@content")
    :gsub("%(%s*#set!%s+injection%.language%s+[^%s%)]+%s*%)", "")
  return vim.treesitter.query.parse("python", src)
end

local JS_QUERY = load_js_query()

local function apply_js_marks(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, JS_NS, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "python")
  if not ok then return end
  local tree = parser:parse()[1]
  if not tree then return end
  for id, node in JS_QUERY:iter_captures(tree:root(), bufnr, 0, -1) do
    if JS_QUERY.captures[id] == "content" then
      local sr, sc, er, ec = node:range()
      vim.api.nvim_buf_set_extmark(bufnr, JS_NS, sr, sc, {
        end_row = er,
        end_col = ec,
        hl_group = "@python.js_embedded",
        priority = 200,
      })
    end
  end
end

local bufnr = vim.api.nvim_get_current_buf()
apply_js_marks(bufnr)
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  buffer = bufnr,
  callback = function() apply_js_marks(bufnr) end,
})

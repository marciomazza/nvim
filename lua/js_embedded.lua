-- Visually distinguish strings that contain injected JavaScript
-- (see after/queries/<lang>/injections.scm for which patterns qualify).
-- highlights.scm priority tricks don't reliably override injection subtree
-- highlights, so we apply extmarks directly at priority 200, which layers
-- a bg tint on top of the per-token JS colors from the injection.

local M = {}

local HL = "@js_embedded"

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
  vim.api.nvim_set_hl(0, HL, { bg = bg })
end

-- Reuse the patterns from injections.scm (single source of truth).
-- Strip injection-only directives so the query can be used for highlights.
local function load_js_query(lang)
  local path = vim.fn.stdpath("config") .. "/after/queries/" .. lang .. "/injections.scm"
  local src = table
    .concat(vim.fn.readfile(path), "\n")
    :gsub("@injection%.content", "@content")
    :gsub("%(%s*#set!%s+injection%.language%s+[^%s%)]+%s*%)", "")
  return vim.treesitter.query.parse(lang, src)
end

function M.attach(lang)
  set_js_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = set_js_hl })

  local ns = vim.api.nvim_create_namespace(lang .. "_js_embedded")
  local query = load_js_query(lang)

  local function apply_js_marks(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
    if not ok then return end
    local tree = parser:parse()[1]
    if not tree then return end
    for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      if query.captures[id] == "content" then
        local sr, sc, er, ec = node:range()
        vim.api.nvim_buf_set_extmark(bufnr, ns, sr, sc, {
          end_row = er,
          end_col = ec,
          hl_group = HL,
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
end

return M

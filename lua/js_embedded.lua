-- Visually distinguish strings that contain injected JavaScript
-- (see after/queries/<lang>/injections.scm for which patterns qualify) and,
-- where the host language paints its own @string over the region (rust's
-- `format!` macro injection does), re-stamp the JS token highlights on top.

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

function M.attach(lang)
  set_js_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = set_js_hl })

  local ns = vim.api.nvim_create_namespace(lang .. "_js_embedded")
  local js_hl = vim.treesitter.query.get("javascript", "highlights")

  local function apply(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
    if not ok or not parser then return end
    parser:parse(true)
    parser:for_each_tree(function(tstree, ltree)
      if ltree:lang() ~= "javascript" then return end
      local root = tstree:root()
      local sr, sc, er, ec = root:range()
      vim.api.nvim_buf_set_extmark(bufnr, ns, sr, sc, {
        end_row = er,
        end_col = ec,
        hl_group = HL,
        priority = 200,
      })
      if not js_hl then return end
      for id, node in js_hl:iter_captures(root, bufnr) do
        local name = js_hl.captures[id]
        if name:sub(1, 1) ~= "_" then
          local nsr, nsc, ner, nec = node:range()
          vim.api.nvim_buf_set_extmark(bufnr, ns, nsr, nsc, {
            end_row = ner,
            end_col = nec,
            hl_group = "@" .. name,
            priority = 201,
          })
        end
      end
    end)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  apply(bufnr)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = bufnr,
    callback = function() apply(bufnr) end,
  })
end

return M

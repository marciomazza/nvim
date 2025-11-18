local M = {}

local function find_ancestor(node, node_types)
  while node do
    if vim.tbl_contains(node_types, node:type()) then
      return node
    end
    node = node:parent()
  end
end

-- copied from MiniSurround.gen_spec.input.treesitter
-- because it's a local inner function there
-- # TODO: ask the author to make it public, perhaps via a PR
local function ts_range_to_region(r)
  -- The `master` branch of 'nvim-treesitter' can return "range four" format
  -- if it uses custom directives, like `#make-range!`. Due to the fact that
  -- it doesn't fully mock the `TSNode:range()` method to return "range six".
  -- TODO: Remove after 'nvim-treesitter' `master` branch support is dropped.
  local offset = #r == 4 and -1 or 0
  local res = {
    from = { line = r[1] + 1, col = r[2] + 1 },
    to = { line = r[4 + offset] + 1, col = r[5 + offset] },
  }
  -- NOTE: Adjust "row-exclusive, col-0" range that means "all previous row
  -- including the newline character"
  if res.to.col == 0 then
    res.to.line = res.to.line - 1
    res.to.col = vim.fn.col({ res.to.line, "$" })
  end
  return res
end

function M.surround_tag_input()
  local ts = vim.treesitter
  local node = ts.get_node({ ignore_injections = false })
  local element = find_ancestor(node, { "element", "script_element", "style_element" })
  if not element then
    return
  end
  local start_tag, end_tag = element:child(0), element:child(element:child_count() - 1)
  return {
    left = ts_range_to_region(ts.get_range(start_tag)),
    right = ts_range_to_region(ts.get_range(end_tag)),
  }
end

function M.get_element()
  local ts = vim.treesitter
  local node = ts.get_node({ ignore_injections = false })
  return find_ancestor(node, { "element" })
end

return M

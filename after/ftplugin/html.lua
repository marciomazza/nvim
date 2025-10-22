local function find_ancestor(node, node_type)
  local current = node
  while current do
    if current:type() == node_type then
      return current
    end
    current = current:parent()
  end
end

-- copied from MiniSurround.gen_spec.input.treesitter
-- because it's a local inner function there
-- # TODO: ask the author to make it public, perhaps via a PR
local ts_range_to_region = function(r)
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

local tag_input = function()
  local element = find_ancestor(vim.treesitter.get_node(), "element")
  if not element then
    return
  end
  local start_tag, end_tag = element:child(0), element:child(element:child_count() - 1)
  return {
    left = ts_range_to_region(vim.treesitter.get_range(start_tag)),
    right = ts_range_to_region(vim.treesitter.get_range(end_tag)),
  }
end

vim.b.minisurround_config = {
  custom_surroundings = {
    t = { input = tag_input },
  },
}

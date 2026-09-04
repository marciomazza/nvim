-- Self-checks for redmine_sync. Run: nvim -l lua/utils/redmine_sync_test.lua

local rs = require("utils.redmine_sync")
local heading_above = rs._heading_above

-- rows:  0 "# Tasks"  2 "## v1"  4 "### triagem"  8 "## v2"
local headings = {
  { row = 0, level = 1, text = "Tasks" },
  { row = 2, level = 2, text = "v1" },
  { row = 4, level = 3, text = "triagem" },
  { row = 8, level = 2, text = "v2" },
}

-- item under ### triagem in v1
assert(heading_above(headings, 5, 2) == "v1")
assert(heading_above(headings, 5, 3) == "triagem")

-- item in v1 but above the h3: no category
assert(heading_above(headings, 3, 2) == "v1")
assert(heading_above(headings, 3, 3) == nil)

-- item in v2: the v1 h3 must not leak across the h2
assert(heading_above(headings, 9, 2) == "v2")
assert(heading_above(headings, 9, 3) == nil)

-- item above any h2
assert(heading_above(headings, 1, 2) == nil)

-- get_headings: an indented "### x" is description text, not a section heading
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  "# Tasks",
  "",
  "## v1",
  "- [ ] a task @issue(#1)",
  "",
  "  some description",
  "  ### sugestão",
  "  - an idea",
})
vim.bo[buf].filetype = "markdown"
vim.treesitter.get_parser(buf, "markdown"):parse()
local got = vim.tbl_map(function(h) return h.text end, rs._get_headings(buf))
assert(vim.deep_equal(got, { "Tasks", "v1" }), vim.inspect(got))

print("ok")

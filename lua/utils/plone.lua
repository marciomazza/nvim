local function get_instance_script_source(root_dir)
  -- try some possible instance scripts and return the contents of the first one found
  local scripts = { "bin/instance", "bin/restore" }
  for _, script in ipairs(scripts) do
    local path = require("plenary.path"):new(root_dir, script)
    if path:exists() then
      return path:read()
    end
  end
end

local function get_paths_from_instance_script(root_dir)
  local src = get_instance_script_source(root_dir)
  local ts = vim.treesitter
  local root = ts.get_string_parser(src, "python"):parse()[1]:root()
  local query = ts.query.parse(
    "python",
    [[
  (assignment
    left: (_) @left (#match? @left "^sys\\.path\\[0:0\\]$")
    right: (list (string (string_content) @content)))
]]
  )
  local paths = vim.iter(query:iter_captures(root, src, 0, -1)):map(function(id, node)
    if query.captures[id] == "content" then
      return ts.get_node_text(node, src)
    end
  end)
  return paths:totable()
end

local M = {}

function M.get_buildout_paths()
  local root_dir = vim.fs.root(0, "buildout.cfg")
  return root_dir and get_paths_from_instance_script(root_dir)
end

return M

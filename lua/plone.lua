local function read_file_contents(file)
  local f = io.open(file, "rb")
  if f == nil then
    return nil
  else
    local contents = f:read("*all")
    f:close()
    return contents
  end
end

local function get_instance_script_contents(root_dir)
  -- try some possible instance scripts and return the contents of the first one found
  for _, script_path in ipairs({ 'bin/instance', 'bin/client' }) do
    local contents = read_file_contents(root_dir .. '/' .. script_path)
    if contents ~= nil then
      return contents
    end
  end
end

-- splits a path string like "'dir1', 'dir2', 'dir3',"
-- into a list of paths
local function get_path_list_from_string(path_string)
  local paths = {}
  for w in path_string:gmatch("'([^']*)',%s*") do
    table.insert(paths, w)
  end
  return paths
end

local function get_plone_config()
  -- find the root plone directory looking for the buildout.cfg file
  local root_dir = vim.fs.dirname(vim.fs.find({ 'buildout.cfg' }, { upward = true })[1])
  if root_dir == nil then
    return nil -- not at a plone project
  end
  local contents = get_instance_script_contents(root_dir)
  local path_string = string.match(contents, 'sys.path%[0:0%] = %[(.-)%]')
  local extra_paths = get_path_list_from_string(path_string)
  return { root_dir = root_dir, extra_paths = extra_paths }
end

local M = {}

function M.setup(lspconfig)
  lspconfig.util.on_setup =
      lspconfig.util.add_hook_before(
        lspconfig.util.on_setup,
        function(config)
          local plone_config = get_plone_config()
          if plone_config ~= nil then
            config.root_dir = function()
              return plone_config.root_dir
            end
            config.init_options = { workspace = { extraPaths = plone_config.extra_paths } }
          end
        end)
end

return M

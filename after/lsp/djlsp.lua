local methods = vim.lsp.protocol.Methods

local function get_cotton_path(cotton_tag_name)
  local cotton_basename = cotton_tag_name:gsub("%-", "_"):gsub("%.", "/")
  local cotton_path = "/templates/cotton/" .. cotton_basename .. ".html"

  -- try to find inside the closest templates dir
  local path = vim.fs.root(0, "templates") .. cotton_path
  if vim.fn.filereadable(path) == 1 then
    return path
  end

  -- fallback to search all project
  local project_root = vim.fs.root(0, "pyproject.toml")
  local found_path = vim.fn.glob(project_root .. "/**" .. cotton_path)
  if found_path ~= "" then
    return found_path
  end

  -- nothing found => returns the default path for a new file
  return path
end

local function go_to_cotton_definition()
  local element = require("utils.html_tags").get_element()
  if not element then
    return
  end
  local text = vim.treesitter.get_node_text(element, 0)
  local cotton_tag_name = text:match("^<c%-([^%s/>]+)")
  if not cotton_tag_name then
    return
  end
  vim.cmd.edit(get_cotton_path(cotton_tag_name))
  return true
end

---https://github.com/neovim/nvim-lspconfig/blob/master/lsp/djlsp.lua
---@type vim.lsp.Config
return {
  on_attach = function(client, _)
    local base_request = client.request
    client.request = function(_, method, ...)
      if method == methods.textDocument_definition and go_to_cotton_definition() then
        return
      end
      return base_request(_, method, ...)
    end
  end,
}

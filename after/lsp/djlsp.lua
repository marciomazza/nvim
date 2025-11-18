local methods = vim.lsp.protocol.Methods

local function get_cotton_dir()
  -- todo: improve detection of cotton dir
  return vim.fs.root(0, "pyproject.toml") .. "/templates/cotton/"
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
  -- Normalize path and open source file
  local cotton_path = cotton_tag_name:gsub("%-", "_"):gsub("%.", "/")
  local file_path = get_cotton_dir() .. cotton_path .. ".html"
  vim.cmd.edit(file_path)
  return true
end

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

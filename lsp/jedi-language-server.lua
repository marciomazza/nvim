local methods = vim.lsp.protocol.Methods

local fqn_regex = vim.regex([[^\h\w*\(\.\h\w*\)\+$]])

local function get_fully_qualified_name_under_cursor()
  local node = vim.treesitter.get_node():parent():child(1)
  if not (node and node:type() == "string_content") then
    return
  end
  local text = vim.treesitter.get_node_text(node, 0)
  if fqn_regex:match_str(text) then
    return text
  end
end

local function build_fake_definition_params(name)
  -- as a trick we prepare a valid python import snippet for the language server
  local uri = string.format("file://%s.py", vim.fn.tempname())
  local module, obj = name:match("^(.*)%.([^%.]+)$")
  local fake_source = string.format("from %s import %s", module, obj)
  local open_params = {
    textDocument = { uri = uri, languageId = "python", version = 0, text = fake_source }
  }
  local definition_params = {
    textDocument = { uri = uri }, position = { line = 0, character = #fake_source }
  }
  return open_params, definition_params
end

local function build_params_for_quoted_name_def(client)
  local name = get_fully_qualified_name_under_cursor()
  if not name then
    return
  end
  local open_params, definition_params = build_fake_definition_params(name)
  client.notify(methods.textDocument_didOpen, open_params)
  return definition_params
end

---@type vim.lsp.Config
return {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_markers = { "buildout.cfg" }, -- for plone
  before_init = function(params, _)
    local plone_config = require "plone".get_plone_config()
    if plone_config ~= nil then
      params.initializationOptions = { workspace = { extraPaths = plone_config.extra_paths } }
    end
  end,
  on_attach = function(client, _)
    local base_request = client.request
    client.request = function(self, method, params, handler, bufnr_req)
      if method == methods.textDocument_definition then
        params = build_params_for_quoted_name_def(client) or params
      end
      return base_request(self, method, params, handler, bufnr_req)
    end
  end
}

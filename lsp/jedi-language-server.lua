local ts_utils = require "nvim-treesitter.ts_utils"

local methods = vim.lsp.protocol.Methods

local fqn_regex = vim.regex([[^\h\w*\(\.\h\w*\)\+$]])

function get_fully_qualified_name_under_cursor()
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
  local uri = "file://" .. vim.fn.tempname() .. ".py"
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

local function find_name_inside_quotes(client_id)
  local name = get_fully_qualified_name_under_cursor()
  if name == nil then return end
  local client = vim.lsp.get_client_by_id(client_id)
  if client == nil then return end
  local open_params, definition_params = build_fake_definition_params(name)
  client.notify(methods.textDocument_didOpen, open_params)
  local def = client.request_sync(methods.textDocument_definition, definition_params, 1000)
  return def.result
end

local default_handler = vim.lsp.handlers[methods.textDocument_definition]

local function jedi_definition_handler(err, result, ctx, config)
  if result == nil or vim.tbl_isempty(result) then
    -- if no definition was found,
    -- try to find the definition of the fully qualified name inside quotes
    result = find_name_inside_quotes(ctx.client_id)
  end
  -- call the default handler
  default_handler(err, result, ctx, config)
end

---@type vim.lsp.Config
return {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_markers = { "buildout.cfg" }, -- for plone
  handlers = { [methods.textDocument_definition] = jedi_definition_handler },
  before_init = function(params, _)
    local plone_config = require "plone".get_plone_config()
    if plone_config ~= nil then
      params.initializationOptions = { workspace = { extraPaths = plone_config.extra_paths } }
    end
  end,
}

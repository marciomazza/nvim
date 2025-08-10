local ts_utils = require "nvim-treesitter.ts_utils"

local function get_fake_definition_params(module, obj)
  -- as a trick we prepare a valid python import snippet for the language server
  local uri = "file://" .. vim.fn.tempname() .. ".py"
  local source = "from " .. module .. " import " .. obj
  local open_params = {
    textDocument = { uri = uri, languageId = "python", version = 0, text = source }
  }
  local definition_params = {
    textDocument = { uri = uri },
    position = { line = 0, character = #source }
  }
  return open_params, definition_params
end

local function find_name_inside_quotes(client_id)
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end
  local type = node:type()
  -- current node must be at a string
  if type == "string_start" or type == "string_end" then
    node = node:parent():child(1) -- move node to string_content
  end
  if node:type() ~= "string_content" then
    return
  end
  local name = vim.treesitter.get_node_text(node, 0)
  -- the text must be a qualified name (e.g. "example.file.name")
  local module, obj = name:match("^(.*)%.([^%.]+)$")
  if not module then
    return
  end
  local client = vim.lsp.get_client_by_id(client_id)
  -- send source to the language server
  local open_params, definition_params = get_fake_definition_params(module, obj)
  client.notify("textDocument/didOpen", open_params)
  local def = client.request_sync("textDocument/definition", definition_params, 1000)
  return def.result
end

local default_handler = vim.lsp.handlers["textDocument/definition"]

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
  handlers = { ["textDocument/definition"] = jedi_definition_handler },
  before_init = function(params, _)
    local plone_config = require "plone".get_plone_config()
    if plone_config ~= nil then
      params.initializationOptions = { workspace = { extraPaths = plone_config.extra_paths } }
    end
  end,
}

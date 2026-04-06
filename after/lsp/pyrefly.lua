local fully_qualified_name_regex = vim.regex([[^\h\w*\(\.\h\w*\)\+$]])

local function get_fully_qualified_name_under_cursor()
  local node = vim.treesitter.get_node():parent():child(1)
  if not (node and node:type() == "string_content") then
    return
  end
  local text = vim.treesitter.get_node_text(node, 0)
  if fully_qualified_name_regex:match_str(text) then
    return text
  end
end

local function build_fake_definition_params(name)
  -- as a trick we prepare a valid python import snippet for the language server
  local uri = vim.uri_from_bufnr(0):gsub("%.py$", "_fake.py")
  local module, obj = name:match("^(.*)%.([^%.]+)$")
  local fake_source = string.format("from %s import %s", module, obj)
  local open_params = {
    textDocument = { uri = uri, languageId = "python", version = 0, text = fake_source },
  }
  local definition_params = {
    textDocument = { uri = uri },
    position = { line = 0, character = #fake_source },
  }
  return open_params, definition_params
end

local methods = vim.lsp.protocol.Methods

---@param client vim.lsp.Client
local function build_params_for_quoted_name_def(client)
  local name = get_fully_qualified_name_under_cursor()
  if not name then
    return
  end
  local open_params, definition_params = build_fake_definition_params(name)
  client:notify(methods.textDocument_didOpen, open_params)
  return definition_params
end

-- Pytest fixture support

local function find_pytest(dir)
  local venv = vim.fs.find(".venv/bin/pytest", { path = dir, upward = true, type = "file" })
  return venv[1] or "pytest"
end

-- Returns func_name, fixture_name if cursor is on a parameter of a test_* function.
local function get_fixture_and_test_at_cursor()
  local node = vim.treesitter.get_node()
  if not node or node:type() ~= "identifier" then
    return
  end

  local fixture_name = vim.treesitter.get_node_text(node, 0)
  local p = node:parent()

  if p and (p:type() == "typed_parameter" or p:type() == "default_parameter") then
    p = p:parent()
  end

  if not p or p:type() ~= "parameters" then
    return
  end

  local func = p:parent()
  if not func or func:type() ~= "function_definition" then
    return
  end

  for i = 0, func:child_count() - 1 do
    local child = func:child(i)
    if child:type() == "identifier" then
      local func_name = vim.treesitter.get_node_text(child, 0)
      if func_name:match("^test_") then
        return func_name, fixture_name
      end
      break
    end
  end
end

local function parse_fixtures_output(lines, cwd)
  local fixtures = {}
  for _, line in ipairs(lines) do
    local name, path, lnum = line:match("^(%w+) %-%- (.+):(%d+)$")
    if name then
      local abs = vim.fn.fnamemodify(cwd .. "/" .. path, ":p")
      fixtures[name] = { abs, tonumber(lnum) }
    end
  end
  return fixtures
end

local function goto_fixture(fixture_name, filepath, func_name)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  local pytest = find_pytest(dir)
  local cwd = vim.fs.root(dir, { "pyproject.toml", "setup.py", "setup.cfg" }) or dir
  local node_id = filepath .. "::" .. func_name

  vim.system(
    { pytest, "--fixtures-per-test", "--no-header", "-q", node_id },
    { text = true, cwd = cwd },
    function(result)
      local lines = vim.split(result.stdout or "", "\n")
      local fixtures = parse_fixtures_output(lines, cwd)
      local def = fixtures[fixture_name]
      if not def then
        return
      end
      vim.schedule(function()
        vim.lsp.util.show_document({
          uri = vim.uri_from_fname(def[1]),
          range = {
            start = { line = def[2] - 1, character = 0 },
            ["end"] = { line = def[2] - 1, character = 0 },
          },
        }, "utf-8", { focus = true })
      end)
    end
  )
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/pyrefly.lua
---@type vim.lsp.Config
return {
  on_attach = function(client, bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    local base_request = client.request
    client.request = function(self, method, params, handler, bufnr_req)
      if method == methods.textDocument_definition then
        params = build_params_for_quoted_name_def(client) or params

        local func_name, fixture_name = get_fixture_and_test_at_cursor()
        if fixture_name and func_name then
          local orig_handler = handler
          handler = function(err, result, ctx, config)
            if not err and (not result or #result == 0) then
              goto_fixture(fixture_name, filename, func_name)
            else
              orig_handler(err, result, ctx, config)
            end
          end
        end
      end
      return base_request(self, method, params, handler, bufnr_req)
    end
  end,
}

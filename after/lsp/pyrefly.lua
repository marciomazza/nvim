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

-- { filepath = { fixture_name = { abs_path, lnum } } }
local fixture_cache = {}

local function find_pytest(dir)
  local venv = vim.fs.find(".venv/bin/pytest", { path = dir, upward = true, type = "file" })
  return venv[1] or "pytest"
end

-- Returns fixture_name if cursor is on a parameter of a test_* function
-- or a @pytest.fixture decorated function.
local function get_fixture_at_cursor()
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

  -- test_* function
  for i = 0, func:child_count() - 1 do
    local child = func:child(i)
    if child:type() == "identifier" then
      if vim.treesitter.get_node_text(child, 0):match("^test_") then
        return fixture_name
      end
      break
    end
  end

  -- @pytest.fixture decorated function
  local decorated = func:parent()
  if decorated and decorated:type() == "decorated_definition" then
    for i = 0, decorated:child_count() - 1 do
      local child = decorated:child(i)
      if child:type() == "decorator" and vim.treesitter.get_node_text(child, 0):match("fixture") then
        return fixture_name
      end
    end
  end
end

local function parse_fixtures_output(stdout, cwd)
  local fixtures = {}
  for _, line in ipairs(vim.split(stdout, "\n")) do
    -- handles both "name -- path:line" and "name [scope] -- path:line"
    local parts = vim.split(line, " -- ", { plain = true })
    if #parts == 2 then
      local name = parts[1]:match("^([%w_]+)")
      local path, lnum = parts[2]:match("^(.+):(%d+)$")
      if name and path and not fixtures[name] then
        fixtures[name] = { vim.fn.fnamemodify(cwd .. "/" .. path, ":p"), tonumber(lnum) }
      end
    end
  end
  return fixtures
end

local function get_cwd(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  return vim.fs.root(dir, { "pyproject.toml", "setup.py", "setup.cfg", "pyrefly.toml", ".git" }) or dir
end

local function build_cache_for_file(filepath)
  if fixture_cache[filepath] ~= nil then
    return
  end
  fixture_cache[filepath] = "loading"
  local cwd = get_cwd(filepath)
  local pytest = find_pytest(cwd)
  local flag = filepath:match("/conftest%.py$") and "--fixtures" or "--fixtures-per-test"
  vim.system({ pytest, flag, "--no-header", "-q", filepath }, { text = true, cwd = cwd }, function(result)
    fixture_cache[filepath] = parse_fixtures_output(result.stdout or "", cwd)
  end)
end

local function goto_pytest_fixture(fixture_name, filepath)
  build_cache_for_file(filepath)
  if type(fixture_cache[filepath]) ~= "table" then
    vim.defer_fn(function()
      goto_pytest_fixture(fixture_name, filepath)
    end, 300)
    return
  end
  local def = fixture_cache[filepath][fixture_name]
  if not def then
    return
  end
  vim.lsp.util.show_document({
    uri = vim.uri_from_fname(def[1]),
    range = {
      start = { line = def[2] - 1, character = 0 },
      ["end"] = { line = def[2] - 1, character = 0 },
    },
  }, "utf-8", { focus = true })
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/pyrefly.lua
---@type vim.lsp.Config
return {

  -- fixme: this was necessary for pyrefly lsp to recognise the workspace
  -- revisit this  later, it should not be necessary!!!
  root_dir = function(fname)
    return vim.fs.root(fname, { "pyproject.toml", "setup.py", "setup.cfg", "pyrefly.toml", ".git" })
  end,

  on_attach = function(client, bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if filename:match("/test_[^/]+%.py$") or filename:match("/[^/]+_test%.py$") or filename:match("/conftest%.py$") then
      build_cache_for_file(filename)

      vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function()
          fixture_cache[filename] = nil
          build_cache_for_file(filename)
        end,
      })
    end

    local base_request = client.request
    client.request = function(self, method, params, handler, bufnr_req)
      if method == methods.textDocument_definition then
        params = build_params_for_quoted_name_def(client) or params

        local fixture_name = get_fixture_at_cursor()
        if fixture_name then
          local orig_handler = handler
          handler = function(err, result, ctx, config)
            if not err and (not result or #result == 0) then
              goto_pytest_fixture(fixture_name, vim.api.nvim_buf_get_name(ctx.bufnr))
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

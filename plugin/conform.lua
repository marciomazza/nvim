vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

local function python_pre_injected(self, ctx, lines, callback)
  local query = vim.treesitter.query.get("python", "injections")
  if not query then return callback(nil, lines) end
  local root = vim.treesitter.get_parser(ctx.buf):trees()[1]:root()

  local nodes = vim
    .iter(query:iter_captures(root, ctx.buf))
    :filter(function(id) return query.captures[id] == "injection.content" end)
    :map(function(_, node) return node end)
    :totable()
  if #nodes == 0 then return callback(nil, lines) end

  local text = table.concat(lines, "\n")
  local slots = {}
  local replacements = {}

  local function add_replace(start_byte, end_byte, replacement)
    table.insert(
      replacements,
      { start_byte = start_byte, end_byte = end_byte, replace = replacement }
    )
  end

  local function register_slot(content, start_byte, end_byte)
    slots[#slots + 1] = content
    local placeholder = "__SLOT_" .. #slots .. "__"
    local pad = (end_byte - start_byte) - #placeholder
    if pad > 0 then placeholder = placeholder .. string.rep("_", pad) end
    add_replace(start_byte, end_byte, placeholder)
  end

  local last_string_id = nil
  for _, node in ipairs(nodes) do
    local string_node = node:parent()
    local string_id = string_node:id()
    if string_id == last_string_id then goto continue end
    last_string_id = string_id
    for child in string_node:iter_children() do
      local _, _, child_start, _, _, child_end = child:range(true)
      if child:type() == "interpolation" then
        register_slot(vim.treesitter.get_node_text(child, ctx.buf), child_start, child_end)
      end
    end
    ::continue::
  end

  local prev_end = 0
  local replaced_text = vim
    .iter(replacements)
    :map(function(r)
      local slice_before = text:sub(prev_end + 1, r.start_byte)
      prev_end = r.end_byte
      return { slice_before, r.replace }
    end)
    :flatten()
    :join("") .. text:sub(prev_end + 1)

  vim.b[ctx.buf].fstring_js_slots = slots
  callback(nil, vim.split(replaced_text, "\n"))
end

local function python_post_injected(self, ctx, lines, callback)
  local slots = vim.b[ctx.buf].fstring_js_slots
  if not slots then return callback(nil, lines) end
  vim.b[ctx.buf].fstring_js_slots = nil
  local text = table.concat(lines, "\n")
  text = text:gsub("__SLOT_(%d+)_+", function(i) return slots[tonumber(i)] end)
  callback(nil, vim.split(text, "\n"))
end

local function pre_js_in_py(self, ctx, lines, callback)
  vim.b[ctx.buf].was_single_line = #lines == 1
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("{{", "{__BRACKET_START__;"):gsub("}}", ";__BRACKET_END__;}")
  end
  callback(nil, lines)
end

local function trim_single_end_semicolon(lines)
  local n = 0
  for _, l in ipairs(lines) do
    if l:match(";$") then n = n + 1 end
  end
  if n == 1 then lines[#lines] = lines[#lines]:gsub(";$", "") end
end

local injected_print_width
local function get_injected_print_width()
  if injected_print_width then return injected_print_width end
  local path = vim.fn.stdpath("config") .. "/.oxfmtrc.injected.json"
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  injected_print_width = (ok and decoded.printWidth) or 80
  return injected_print_width
end

local function post_js_in_py(self, ctx, lines, callback)
  if vim.b[ctx.buf].was_single_line then
    local joined = vim.iter(lines):map(vim.trim):join(" ")
    if #joined <= get_injected_print_width() then lines = { joined } end
  end
  trim_single_end_semicolon(lines)
  local text = table.concat(lines, "\n")
  text = text:gsub("{%s*__BRACKET_START__%s*;", "{{")
  text = text:gsub("%s*__BRACKET_END__;(%s*)}", "%1}}")
  callback(nil, vim.split(text, "\n"))
end

local oxc = { "oxlint", "oxfmt" }
local for_htmldjango = { "rustywind", "djangofmt" }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = {
      "python_pre_injected",
      "injected",
      "python_post_injected",
      "ruff_fix",
      "ruff_format",
    },
    htmldjango = for_htmldjango,
    html = for_htmldjango,
    javascript = oxc,
    typescript = oxc,
    json = oxc,
    css = oxc,
    scss = oxc,
    yaml = oxc,
    toml = { "tombi" },
    typst = { "typstyle" },
    markdown = { "oxfmt" },
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
  formatters = {
    python_pre_injected = { format = python_pre_injected },
    python_post_injected = { format = python_post_injected },
    pre_js_in_py = { format = pre_js_in_py },
    post_js_in_py = { format = post_js_in_py },
    injected = {
      options = {
        lang_to_formatters = {
          javascript = {
            "pre_js_in_py",
            "oxlint",
            "oxfmt_injected",
            "post_js_in_py",
            "trim_single_semicolon",
          },
        },
      },
    },
    oxfmt_injected = {
      inherit = "oxfmt",
      append_args = { "-c", vim.fn.stdpath("config") .. "/.oxfmtrc.injected.json" },
    },
    ruff_fix = {
      append_args = { "--unsafe-fixes" },
    },
    oxlint = {
      append_args = { "--fix-suggestions" },
    },
    djangofmt = {
      command = "djangofmt",
      args = { "--quiet", "$FILENAME" },
      stdin = false,
    },
    rustywind = {
      -- skip class/className attrs containing "{" or "}" (e.g. {{ evento.status }}, {% if ... %})
      -- so Django/Jinja template expressions aren't broken/reordered by the tokenizer
      append_args = {
        "--quiet",
        "--custom-regex",
        [[\bclass(?:Name)?\s*=\s*(?:"([^"{}]+)"|'([^'{}]+)')]],
      },
    },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_after_save = function(bufnr)
    local skip_patterns = { "/plone/", "/node_modules/", "/lib/python", "/repos/", "/dist/debug/" }
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local skip = vim.iter(skip_patterns):any(function(pattern) return bufname:match(pattern) end)
    return not skip and {}
  end,
})

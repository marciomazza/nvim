vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

local function find_import_insertion_line_number(bufnr)
  local root = vim.treesitter.get_parser(bufnr):trees()[1]:root()
  for node in root:iter_children() do
    if node:type() == "comment" then
      -- skip initial comments, that might come before the module docstring
    elseif node:type() == "expression_statement" and node:child(0):type() == "string" then
      -- found a module docstring => imports should start at the next line
      local _, _, line_number, _ = node:range()
      return line_number + 2 -- treesitter ranges are 0 based => add 1 more
    else
      return 1 -- no module docstring => imports should start at the very top
    end
  end
end

local utils = require("utils")

local function float_imports_to_top(bufnr, lines)
  local misplaced_imports = vim
    .iter(vim.diagnostic.get(bufnr))
    :filter(function(d) return d.source == "Ruff" and d.user_data.lsp.code == "E402" end)
    :map(function(d) return vim.list_slice(lines, d.lnum + 1, d.end_lnum + 1) end)
    :totable()
  if #misplaced_imports == 0 then return end
  local insertion_index = find_import_insertion_line_number(bufnr)
  for _, block in ipairs(misplaced_imports) do
    utils.move_sublist(lines, block, insertion_index)
    insertion_index = insertion_index + #block
  end
end

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
  local function register_slot(content, start_byte, end_byte)
    slots[#slots + 1] = content
    table.insert(
      replacements,
      { start_byte = start_byte, end_byte = end_byte, placeholder = "__SLOT_" .. #slots .. "__" }
    )
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
      elseif child:type() == "string_content" then
        local child_text = text:sub(child_start + 1, child_end)
        local search_from = 1
        while true do
          local match_start, match_end, captured_braces = child_text:find("{{(.-)}}", search_from)
          if not match_start then break end
          register_slot(
            "{{" .. captured_braces .. "}}",
            child_start + match_start - 1,
            child_start + match_end
          )
          search_from = match_end + 1
        end
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
      return { slice_before, r.placeholder }
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
  text = text:gsub("__SLOT_(%d+)__", function(i) return slots[tonumber(i)] end)
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
      "float_imports_to_top",
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
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
  formatters = {
    python_pre_injected = { format = python_pre_injected },
    python_post_injected = { format = python_post_injected },
    injected = {
      options = {
        lang_to_formatters = {
          javascript = { "oxlint", "oxfmt_injected", "trim_single_semicolon" },
        },
      },
    },
    oxfmt_injected = {
      inherit = "oxfmt",
      append_args = { "-c", vim.fn.stdpath("config") .. "/.oxfmtrc.injected.json" },
    },
    trim_single_semicolon = {
      format = function(_, _, lines, callback)
        local n = 0
        for _, l in ipairs(lines) do
          if l:match(";$") then n = n + 1 end
        end
        if n == 1 then lines[#lines] = lines[#lines]:gsub(";$", "") end
        callback(nil, lines)
      end,
    },
    float_imports_to_top = {
      -- keep this until ruff implements float-to-top (https://github.com/astral-sh/ruff/issues/6514)
      format = function(_, ctx, lines, callback)
        float_imports_to_top(ctx.buf, lines)
        callback(nil, lines)
      end,
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
      append_args = { "--quiet", "--config-file", ".rustywind.json" },
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

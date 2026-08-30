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
    -- Mark f-string regions so post_js_injected knows to re-double every brace
    -- the formatter emits (a lone `{` in an f-string is an interpolation).
    local prefix = string_node:child(0)
    local is_fstring = prefix
      and prefix:type() == "string_start"
      and vim.treesitter.get_node_text(prefix, ctx.buf):lower():find("f", 1, true)
    local marker_pos = nil
    for child in string_node:iter_children() do
      local _, _, child_start, _, _, child_end = child:range(true)
      if child:type() == "interpolation" then
        register_slot(vim.treesitter.get_node_text(child, ctx.buf), child_start, child_end)
      elseif child:type() == "string_content" then
        -- Sit the marker right after the last real character, not on the
        -- (less-indented) closing-quote line, so it can't lower the block's
        -- detected common indent when conform dedents it.
        local trimmed = vim.treesitter.get_node_text(child, ctx.buf):gsub("%s+$", "")
        marker_pos = child_start + #trimmed
      end
    end
    if is_fstring and marker_pos then add_replace(marker_pos, marker_pos, "/*__FSTR__*/") end
    ::continue::
  end

  -- The f-string marker is appended after a string's slots but its byte offset
  -- can precede them, so the rebuild below needs the list sorted by position.
  table.sort(replacements, function(a, b)
    if a.start_byte == b.start_byte then
      return a.end_byte < b.end_byte
    else
      return a.start_byte < b.start_byte
    end
  end)

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

-- format!(r#"..."#) raw strings use `{name}` interpolation and `{{`/`}}` for
-- literal braces. Slot the interpolations out (as bare identifiers so the JS
-- formatter keeps them on their own line) and mark each region so
-- pre/post_js_injected unescape the doubled braces around oxfmt, exactly as the
-- f-string path does for Python. The trailing `;` is tracked per slot because
-- oxfmt adds one to every statement whether the source had it or not.
local function rust_pre_injected(self, ctx, lines, callback)
  local query = vim.treesitter.query.get("rust", "injections")
  if not query then return callback(nil, lines) end
  local text = table.concat(lines, "\n")
  -- Parse the text we were handed, not the buffer: an earlier formatter
  -- (rustfmt) may have shifted every byte offset already.
  local ok, parser = pcall(vim.treesitter.get_string_parser, text, "rust")
  if not ok then return callback(nil, lines) end
  local root = parser:parse()[1]:root()

  local slots = {}
  local regions = {}

  for id, node in query:iter_captures(root, text) do
    -- Our JS injections capture `string_content`; the upstream macro->rust
    -- rule captures the whole `token_tree` — skip that one.
    if query.captures[id] == "injection.content" and node:type() == "string_content" then
      local macro = node:parent()
      while macro and macro:type() ~= "macro_invocation" do
        macro = macro:parent()
      end
      if macro then
        local _, _, start_byte, _, _, end_byte = node:range(true)
        local body = text:sub(start_byte + 1, end_byte)
        body = body:gsub("{{", "\1"):gsub("}}", "\2")
        body = body:gsub("(%b{})(;?)([^\n]*)", function(expr, semi, rest)
          slots[#slots + 1] = { text = expr, semi = semi ~= "" }
          -- In statement position emit a `;` so the placeholder is a complete
          -- statement (a bare identifier before a `[`/`(` line trips up ASI).
          local stmt = semi ~= "" or rest:match("^%s*$") ~= nil
          return "__RUSTFMTSLOT" .. #slots .. "__" .. (stmt and ";" or "") .. rest
        end)
        body = body:gsub("\1", "{{"):gsub("\2", "}}")
        body = body:gsub("(%s*)$", "/*__FSTR__*/%1", 1)
        regions[#regions + 1] = { start_byte, end_byte, body }
      end
    end
  end

  if #regions == 0 then return callback(nil, lines) end
  vim.b[ctx.buf].rust_js_slots = slots

  table.sort(regions, function(a, b) return a[1] > b[1] end)
  for _, r in ipairs(regions) do
    text = text:sub(1, r[1]) .. r[3] .. text:sub(r[2] + 1)
  end
  callback(nil, vim.split(text, "\n"))
end

local function rust_post_injected(self, ctx, lines, callback)
  local slots = vim.b[ctx.buf].rust_js_slots
  if not slots then return callback(nil, lines) end
  vim.b[ctx.buf].rust_js_slots = nil
  local text = table.concat(lines, "\n")
  text = text:gsub("__RUSTFMTSLOT(%d+)__(;?)", function(i)
    local slot = slots[tonumber(i)]
    return slot.text .. (slot.semi and ";" or "")
  end)
  -- Safety net: if the JS formatter bailed on a region the marker survives.
  text = text:gsub("%s*/%*__FSTR__%*/", "")
  callback(nil, vim.split(text, "\n"))
end

local function pre_js_injected(self, ctx, lines, callback)
  vim.b[ctx.buf].was_single_line = #lines == 1
  local text = table.concat(lines, "\n")
  if text:find("/*__FSTR__*/", 1, true) then
    vim.b[ctx.buf].is_fstring = true
    text = text:gsub("{{", "{"):gsub("}}", "}")
  end
  callback(nil, vim.split(text, "\n"))
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

local function post_js_injected(self, ctx, lines, callback)
  -- Strip the marker first: later steps inspect the last line's trailing `;`.
  if vim.b[ctx.buf].is_fstring then
    vim.b[ctx.buf].is_fstring = nil
    -- A lone brace in an f-string is interpolation syntax; the formatter's
    -- literal braces must all be doubled. Interpolations are still __SLOT__
    -- tokens here, so they keep their single braces after restore.
    local text = table.concat(lines, "\n"):gsub("[{}]", { ["{"] = "{{", ["}"] = "}}" })
    text = text:gsub("%s*/%*__FSTR__%*/", "")
    lines = vim.split(text, "\n")
  end
  if vim.b[ctx.buf].was_single_line then
    local joined = vim.iter(lines):map(vim.trim):join(" ")
    if #joined <= get_injected_print_width() then lines = { joined } end
  end
  trim_single_end_semicolon(lines)
  callback(nil, lines)
end

local oxc = { "oxlint", "oxfmt" }
local for_htmldjango = { "rustywind", "djangofmt" }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- rustfmt last: `injected` reads line numbers straight off the buffer, so
    -- nothing ahead of it may change the line count.
    rust = { "rust_pre_injected", "injected", "rust_post_injected", "rustfmt" },
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
    rust_pre_injected = { format = rust_pre_injected },
    rust_post_injected = { format = rust_post_injected },
    pre_js_injected = { format = pre_js_injected },
    post_js_injected = { format = post_js_injected },
    injected = {
      options = {
        lang_to_formatters = {
          javascript = {
            "pre_js_injected",
            "oxlint",
            "oxfmt_injected",
            "post_js_injected",
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

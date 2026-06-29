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

local oxc = { "oxfmt", "oxlint" }
local for_htmldjango = { "rustywind", "djangofmt" }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "float_imports_to_top", "ruff_fix", "ruff_format" },
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
    float_imports_to_top = {
      -- keep this until ruff implements float-to-top (https://github.com/astral-sh/ruff/issues/6514)
      format = function(self, ctx, lines, callback)
        local out_lines = vim.deepcopy(lines)
        float_imports_to_top(ctx.buf, out_lines)
        callback(nil, out_lines)
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

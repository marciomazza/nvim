local function find_import_insertion_line_number(bufnr)
  local root = vim.treesitter.get_parser(bufnr):trees()[1]:root()
  for node in root:iter_children() do
    if node:type() == "comment" then
      -- skip initial comments, that might come before the module docstring
    elseif node:type() == "expression_statement" and node:child(0):type() == "string" then
      -- found a module docstring => imports should start at the next line
      local _, _, line_number, _ = node:range()
      return line_number + 1
    else
      return 0 -- no module docstring => imports should start at the very top
    end
  end
end

local function float_imports_to_top(bufnr, lines)
  local insertion_index = find_import_insertion_line_number(bufnr) + 1
  for _, d in pairs(vim.diagnostic.get(bufnr)) do
    if d.source == "Ruff" and d.user_data.lsp.code == "E402" then
      table.insert(lines, insertion_index, table.remove(lines, d.lnum + 1))
      insertion_index = insertion_index + 1
    end
  end
end

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "float_imports_to_top", "ruff_organize_imports", "ruff_format" },
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
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      -- skip plone, format everything else
      return not require("plone").is_in_plone_project(bufnr) and {}
    end,
  },
}

local M = {}

--- Build a sorted list of {row, version} from ATX headings in the buffer using treesitter
---@param bufnr integer
---@return {row: integer, version: string}[]
local function get_headings(bufnr)
  local ts_parser = vim.treesitter.get_parser(bufnr, "markdown")
  if not ts_parser then return {} end

  local tree = ts_parser:parse()[1]
  if not tree then return {} end

  local query = vim.treesitter.query.parse("markdown", "(atx_heading) @h")
  local headings = {}

  for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    local row = node:range()
    -- Extract heading text: get the inline child (the title text)
    local text = ""
    for child in node:iter_children() do
      if child:type() == "inline" then
        text = vim.treesitter.get_node_text(child, bufnr)
        break
      end
    end
    if text ~= "" then
      headings[#headings + 1] = { row = row, version = vim.trim(text) }
    end
  end

  table.sort(headings, function(a, b) return a.row < b.row end)
  return headings
end

--- Return the version (heading text) for the heading immediately above `target_row`
---@param headings {row: integer, version: string}[]
---@param target_row integer 0-indexed
---@return string|nil
local function version_for_row(headings, target_row)
  local result = nil
  for _, h in ipairs(headings) do
    if h.row <= target_row then
      result = h.version
    else
      break
    end
  end
  return result
end

--- Extract a clean title from a TodoItem's first line.
--- Strips the list marker and todo unicode marker; stops before any @tag.
---@param item checkmate.TodoItem
---@return string
local function todo_title(item)
  local text = item.todo_text or ""
  -- Remove leading indent + list marker (-, *, +) + todo marker (unicode char) and space
  -- Pattern: optional spaces, list marker, whitespace, non-space (unicode marker), whitespace, rest
  local title = text:match("^%s*[-*+%d.)]%s+%S+%s+(.+)$") or text
  -- Trim from first @tag onward
  title = title:gsub("%s+@%w.*$", "")
  return vim.trim(title)
end

--- Enumerate all todo items that have an @issue tag, with their version (section heading).
--- Loads the file, uses checkmate's parser + treesitter.
---@param filepath string
---@return {version: string, issue: string, title: string, row: integer, state: string}[]
function M.enumerate_issues(filepath)
  -- Initialize checkmate config with defaults if not already done
  local cfg = require("checkmate.config")
  if vim.tbl_isempty(cfg.options) then
    cfg.setup({})
  end

  local bufnr = vim.fn.bufadd(vim.fn.fnamemodify(filepath, ":p"))
  vim.fn.bufload(bufnr)
  vim.bo[bufnr].filetype = "markdown"

  -- Let treesitter parse the buffer
  vim.treesitter.get_parser(bufnr, "markdown"):parse()

  local parser = require("checkmate.parser")
  -- Convert [ ]/[x] markdown syntax to checkmate's unicode markers so discover_todos works
  parser.convert_markdown_to_unicode(bufnr)

  local todo_map = parser.discover_todos(bufnr)
  local headings = get_headings(bufnr)

  local archive_title = (cfg.options.archive and cfg.options.archive.heading and cfg.options.archive.heading.title)
    or "Archive"

  local results = {}
  for _, item in pairs(todo_map) do
    local version = version_for_row(headings, item.range.start.row) or "(no section)"
    if version ~= archive_title then
      local issue_meta = item.metadata.by_tag["issue"]
      results[#results + 1] = {
        version = version,
        issue = issue_meta and issue_meta.value or nil,
        title = todo_title(item),
        row = item.range.start.row,
        state = item.state,
      }
    end
  end

  table.sort(results, function(a, b) return a.row < b.row end)
  return results
end

return M

local M = {}

---@class RedmineVersion
---@field id integer
---@field name string
---@field status string

---@class RedmineIssue
---@field id integer
---@field subject string
---@field status string|nil
---@field version string|nil
---@field assigned_to string|nil

---@class IssueFields
---@field subject string
---@field status string|nil
---@field version string|nil

---@class TodoIssue : IssueFields
---@field id string|nil
---@field row integer
---@field state string

---------------------------------------------------------------------------------
-- REDMINE -> TODO.MD
---------------------------------------------------------------------------------

--- Load configuration from .redmine.env.json in the current working directory (project root)
--- Validates required fields: project_url, base_url, token.
---@return table
local function load_env()
  local path = vim.fn.getcwd() .. "/.redmine.env.json"
  local f = assert(io.open(path, "r"), "Could not open " .. path)
  local raw = f:read("*a")
  f:close()
  local env = vim.json.decode(raw)

  for _, field in ipairs({ "project_url", "base_url", "token" }) do
    if not env[field] or env[field] == "" then
      error(field .. " not found or empty in .redmine.env.json")
    end
  end

  return env
end

local env = load_env()

---@param url string
---@param extra_args string[]
---@return string
local function redmine_request(url, extra_args)
  local cmd = { "curl", "-sf", "-k", "-H", "X-Redmine-API-Key: " .. env.token }
  vim.list_extend(cmd, extra_args)
  cmd[#cmd + 1] = url
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    error("curl failed (exit " .. result.code .. "): " .. (result.stderr or ""))
  end
  return result.stdout
end

---@param stdout string
---@return table
local function json_decode(stdout)
  local ok, decoded = pcall(vim.json.decode, stdout)
  if not ok then
    error("JSON decode error: " .. tostring(decoded))
  end
  return decoded
end

---@param url string
---@return table
local function redmine_get(url)
  return json_decode(redmine_request(url, { "-H", "Accept: application/json" }))
end

---@param url string
---@param body table
local function redmine_put(url, body)
  redmine_request(
    url,
    { "-X", "PUT", "-H", "Content-Type: application/json", "-d", vim.json.encode(body) }
  )
end

---@param url string
---@param body table
---@return table
local function redmine_post(url, body)
  return json_decode(
    redmine_request(
      url,
      { "-X", "POST", "-H", "Content-Type: application/json", "-d", vim.json.encode(body) }
    )
  )
end

--- Return all versions for the configured Redmine project, sorted by name.
---@return RedmineVersion[]
function M.versions()
  local data = redmine_get(env.project_url .. "versions.json")
  local versions = vim.tbl_map(
    function(v) return { id = v.id, name = v.name, status = v.status } end,
    data.versions or {}
  )
  table.sort(versions, function(a, b) return a.name < b.name end)
  return versions
end

--- Return all open issues for the configured Redmine project.
---@return RedmineIssue[]
function M.open_issues()
  local data = redmine_get(env.project_url .. "issues.json?status_id=open&assigned_to_id=me")
  local all_issues = {}
  for _, iss in ipairs(data.issues or {}) do
    all_issues[#all_issues + 1] = {
      id = iss.id,
      subject = iss.subject,
      status = iss.status and iss.status.name or nil,
      version = iss.fixed_version and iss.fixed_version.name or nil,
      assigned_to = iss.assigned_to and iss.assigned_to.name or nil,
    }
  end
  return all_issues
end

--- Maps checkmate todo states to Redmine status names.
local state_to_redmine_status = {
  in_progress = "In Progress",
  checked = "Resolved",
  cancelled = "Rejected",
}

--- Generate a markdown report of all open Redmine issues grouped by version then status.
---@return string
function M.open_issues_report()
  local issues = M.open_issues()

  local status_rank = {}
  for i, s in ipairs(env.open_statuses or {}) do
    status_rank[s.name] = i
  end

  local todo_states = require("checkmate.config").options.todo_states or {}
  local default_md = { unchecked = " ", checked = "x" }
  local status_marker = {}
  for state, redmine_status in pairs(state_to_redmine_status) do
    local md_raw = todo_states[state] and todo_states[state].markdown
    local md = (type(md_raw) == "string" and md_raw)
      or (type(md_raw) == "table" and md_raw[1])
      or default_md[state]
      or " "
    status_marker[redmine_status] = "[" .. md .. "]"
  end

  local by_version = {}
  local version_list = {}
  for _, iss in ipairs(issues) do
    local ver = iss.version or "(no version)"
    local st = iss.status or "Unknown"
    if not by_version[ver] then
      by_version[ver] = {}
      version_list[#version_list + 1] = ver
    end
    if not by_version[ver][st] then
      by_version[ver][st] = {}
    end
    table.insert(by_version[ver][st], iss)
  end

  table.sort(version_list)

  local lines = { "# Tarefas" }
  for _, ver in ipairs(version_list) do
    lines[#lines + 1] = ""
    lines[#lines + 1] = "## " .. ver
    local statuses = vim.tbl_keys(by_version[ver])
    table.sort(
      statuses,
      function(a, b) return (status_rank[a] or 999) < (status_rank[b] or 999) end
    )
    for _, st in ipairs(statuses) do
      lines[#lines + 1] = ""
      if st ~= "In Progress" then
        lines[#lines + 1] = "### " .. st
        lines[#lines + 1] = ""
      end
      local marker = status_marker[st] or "[ ]"
      for _, iss in ipairs(by_version[ver][st]) do
        lines[#lines + 1] = "- " .. marker .. " " .. iss.subject .. " @issue(#" .. iss.id .. ")"
      end
    end
  end

  return table.concat(lines, "\n")
end

--- Sync open issues to todo.md in the project root.
--- Creates a new jj change, then overwrites todo.md with the report.
function M.populate_todo()
  local report = M.open_issues_report()

  local root = vim.fn.getcwd()
  local jj = vim.system({ "jj", "new" }, { text = true, cwd = root }):wait()
  if jj.code ~= 0 then
    error("jj new failed: " .. (jj.stderr or ""))
  end

  local path = root .. "/todo.md"
  local f = assert(io.open(path, "w"), "Could not write " .. path)
  f:write(report .. "\n")
  f:close()

  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 then
    vim.api.nvim_buf_call(bufnr, function() vim.cmd("edit") end)
  end
end

---------------------------------------------------------------------------------
-- TODO.MD -> REDMINE
---------------------------------------------------------------------------------

--- Build a sorted list of ATX headings with their level and text.
---@param bufnr integer
---@return {row: integer, level: integer, text: string}[]
local function get_headings(bufnr)
  local ts_parser = vim.treesitter.get_parser(bufnr, "markdown")
  if not ts_parser then
    return {}
  end
  local tree = ts_parser:parse()[1]
  if not tree then
    return {}
  end

  local query = vim.treesitter.query.parse("markdown", "(atx_heading) @h")
  local headings = {}

  for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    local row = node:range()
    local level, text = 0, ""
    for child in node:iter_children() do
      local t = child:type()
      if t:match("^atx_h%d_marker$") then
        level = tonumber(t:match("%d")) or 0
      elseif t == "inline" then
        text = vim.trim(vim.treesitter.get_node_text(child, bufnr))
      end
    end
    if text ~= "" then
      headings[#headings + 1] = { row = row, level = level, text = text }
    end
  end

  table.sort(headings, function(a, b) return a.row < b.row end)
  return headings
end

--- Return the version (h1) and status (h2) for the headings immediately above `target_row`.
---@param headings {row: integer, level: integer, text: string}[]
---@param target_row integer 0-indexed
---@return string|nil version, string|nil status
local function context_for_row(headings, target_row)
  local version, status = nil, nil
  for _, h in ipairs(headings) do
    if h.row <= target_row then
      if h.level == 2 then
        version = h.text
        status = nil
      elseif h.level == 3 then
        status = h.text
      end
    else
      break
    end
  end
  return version, status
end

--- Extract a clean title from a TodoItem's first line.
--- Strips the list marker and todo unicode marker; stops before any @tag.
---@param item {todo_text: string|nil}
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
---@return TodoIssue[]
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

  local results = {}
  for _, item in pairs(todo_map) do
    local version, status = context_for_row(headings, item.range.start.row)
    version = version or "(no section)"
    status = status or state_to_redmine_status[item.state]
    local issue_meta = item.metadata.by_tag["issue"]
    results[#results + 1] = {
      version = version,
      status = status,
      id = issue_meta and issue_meta.value or nil,
      subject = todo_title(item),
      row = item.range.start.row,
      state = item.state,
    }
  end

  table.sort(results, function(a, b) return a.row < b.row end)
  return results
end

--- Load env, build status_id and version_id lookup tables.
---@return table status_id_by_name, table version_id_by_name
local function prepare_issue_context()
  local status_id_by_name = {}
  for _, s in ipairs(env.open_statuses or {}) do
    status_id_by_name[s.name] = s.id
  end
  for _, s in ipairs(env.closed_statuses or {}) do
    status_id_by_name[s.name] = s.id
  end

  local versions = M.versions()
  local version_id_by_name = {}
  for _, v in ipairs(versions) do
    version_id_by_name[v.name] = v.id
  end

  return status_id_by_name, version_id_by_name
end

--- Build common issue payload fields (subject, status_id, fixed_version_id).
---@param item IssueFields
---@param status_id_by_name table
---@param version_id_by_name table
---@return table
local function build_issue_fields(item, status_id_by_name, version_id_by_name)
  local fields = { subject = item.subject }
  fields.status_id = status_id_by_name[item.status]
  if item.version ~= "Archive" then
    fields.fixed_version_id = version_id_by_name[item.version]
  end
  return fields
end

--- Update a Redmine issue's subject, status and version from a todo item.
--- Skips fixed_version_id when version is "Archive".
---@param item TodoIssue
function M.update_issue(item)
  local issue_id = item.id and item.id:match("%d+")
  if not issue_id then
    error("missing issue id")
  end

  local status_id_by_name, version_id_by_name = prepare_issue_context()
  local payload = { issue = build_issue_fields(item, status_id_by_name, version_id_by_name) }
  redmine_put(env.base_url .. "issues/" .. issue_id .. ".json", payload)
end

--- Create a new Redmine issue from a todo item that has no @issue tag yet.
--- item.issue must be nil; item.version must match a known version.
---@param item TodoIssue
---@return table decoded response
function M.create_issue(item)
  if item.id ~= nil then
    error("item already has an issue id: " .. tostring(item.id))
  end

  local status_id_by_name, version_id_by_name = prepare_issue_context()

  if not version_id_by_name[item.version] then
    error("unknown version: " .. tostring(item.version))
  end

  local fields = build_issue_fields(item, status_id_by_name, version_id_by_name)
  fields.assigned_to_id = "me"
  fields.tracker = { id = 2, name = "Tarefa" }
  fields.custom_fields = { { id = 31, name = "Tipo de manutenção", value = "Projeto" } }

  return redmine_post(env.project_url .. "issues.json", { issue = fields })
end

--- Update or create the Redmine issue for the todo item on the current cursor line.
--- Creates a new issue when the item has no @issue tag and adds @issue(#id) to the buffer.
function M.update_issue_under_cursor()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local items = M.enumerate_issues(vim.api.nvim_buf_get_name(0))
  for _, item in ipairs(items) do
    if item.row == row then
      if item.id == nil then
        local response = M.create_issue(item)
        local new_id = response.issue and response.issue.id
        if new_id then
          require("checkmate").add_metadata("issue", "#" .. new_id)
        end
        return
      else
        M.update_issue(item)
        return
      end
    end
  end
  error("no issue found on current line")
end

--- Open the Redmine issue URL for the todo item on the current cursor line.
function M.open_issue_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local item =
    require("checkmate.parser").get_todo_item_at_position(bufnr, cursor[1] - 1, cursor[2])
  if not item then
    error("no todo item on current line")
  end
  local issue_meta = item.metadata.by_tag["issue"]
  if not issue_meta then
    error("no @issue tag on current line")
  end
  vim.ui.open(env.base_url .. "issues/" .. issue_meta.value:gsub("^#", ""))
end

return M

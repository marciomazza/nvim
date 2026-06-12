local M = {}

---------------------------------------------------------------------------------
-- REDMINE -> TODO.MD
---------------------------------------------------------------------------------

--- Load configuration from .env.json in the current working directory (project root)
---@return table
local function load_env()
	local path = vim.fn.getcwd() .. "/.env.json"
	local f = assert(io.open(path, "r"), "Could not open " .. path)
	local raw = f:read("*a")
	f:close()
	return vim.json.decode(raw)
end

--- Make a GET request to a Redmine JSON endpoint and return the decoded table.
---@param url string
---@param token string
---@return table|nil, string|nil
local function redmine_get(url, token)
	local result = vim.system(
		{ "curl", "-sf", "-k", "-H", "X-Redmine-API-Key: " .. token, "-H", "Accept: application/json", url },
		{ text = true }
	):wait()

	if result.code ~= 0 then
		return nil, "curl failed (exit " .. result.code .. "): " .. (result.stderr or "")
	end

	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if not ok then
		return nil, "JSON decode error: " .. tostring(decoded)
	end
	return decoded, nil
end

--- Make a PUT request to a Redmine JSON endpoint.
---@param url string
---@param token string
---@param body table  will be JSON-encoded
---@return nil, string|nil
local function redmine_put(url, token, body)
	local result = vim.system({
		"curl", "-sf", "-k", "-X", "PUT",
		"-H", "X-Redmine-API-Key: " .. token,
		"-H", "Content-Type: application/json",
		"-d", vim.json.encode(body),
		url,
	}, { text = true }):wait()

	if result.code ~= 0 then
		return nil, "curl failed (exit " .. result.code .. "): " .. (result.stderr or "")
	end
	return nil, nil
end

--- Make a POST request to a Redmine JSON endpoint and return the decoded response.
---@param url string
---@param token string
---@param body table  will be JSON-encoded
---@return table|nil, string|nil
local function redmine_post(url, token, body)
	local result = vim.system({
		"curl", "-sf", "-k", "-X", "POST",
		"-H", "X-Redmine-API-Key: " .. token,
		"-H", "Content-Type: application/json",
		"-d", vim.json.encode(body),
		url,
	}, { text = true }):wait()

	if result.code ~= 0 then
		return nil, "curl failed (exit " .. result.code .. "): " .. (result.stderr or "")
	end
	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if not ok then
		return nil, "JSON decode error: " .. tostring(decoded)
	end
	return decoded, nil
end

--- Return all versions for the configured Redmine project, sorted by name.
---@return {id: integer, name: string, status: string}[]|nil, string|nil
function M.versions()
	local env = load_env()
	local data, err = redmine_get(
		(env.project_url or error("PROJECT_URL not found in .env")) .. "versions.json",
		env.token or error("TOKEN not found in .env")
	)
	if not data then
		return nil, err
	end

	local versions = vim.tbl_map(
		function(v) return { id = v.id, name = v.name, status = v.status } end,
		data.versions or {}
	)
	table.sort(versions, function(a, b) return a.name < b.name end)
	return versions, nil
end

--- Return all open issues for the configured Redmine project.
---@return {id: integer, subject: string, status: string|nil, version: string|nil, assigned_to: string|nil}[]|nil, string|nil
function M.open_issues()
	local env = load_env()
	local project_url = env.project_url or error("PROJECT_URL not found in .env")
	local token = env.token or error("TOKEN not found in .env")

	local data, err = redmine_get(project_url .. "issues.json?status_id=open&assigned_to_id=me", token)
	if not data then
		return nil, err
	end

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

	return all_issues, nil
end

--- Maps checkmate todo states to Redmine status names.
local state_to_redmine_status = {
	in_progress = "In Progress",
	checked = "Resolved",
	cancelled = "Rejected",
}

--- Generate a markdown report of all open Redmine issues grouped by version then status.
---@return string|nil, string|nil
function M.open_issues_report()
	local env = load_env()
	local issues, err = M.open_issues()
	if not issues then
		return nil, err
	end

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
		table.sort(statuses, function(a, b) return (status_rank[a] or 999) < (status_rank[b] or 999) end)
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

	return table.concat(lines, "\n"), nil
end

--- Sync open issues to todo.md in the project root.
--- Creates a new jj change, then overwrites todo.md with the report.
---@return nil, string|nil
function M.populate_todo()
	local report, err = M.open_issues_report()
	if not report then
		return nil, err
	end

	local root = vim.fn.getcwd()
	local jj = vim.system({ "jj", "new" }, { text = true, cwd = root }):wait()
	if jj.code ~= 0 then
		return nil, "jj new failed: " .. (jj.stderr or "")
	end

	local path = root .. "/todo.md"
	local f = assert(io.open(path, "w"), "Could not write " .. path)
	f:write(report .. "\n")
	f:close()

	local bufnr = vim.fn.bufnr(path)
	if bufnr ~= -1 then
		vim.api.nvim_buf_call(bufnr, function() vim.cmd("edit") end)
	end
	return nil, nil
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
				level = tonumber(t:match("%d"))
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
---@return string|nil, string|nil  version, status
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
---@return {version: string, status: string|nil, issue: string, title: string, row: integer, state: string}[]
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
			issue = issue_meta and issue_meta.value or nil,
			title = todo_title(item),
			row = item.range.start.row,
			state = item.state,
		}
	end

	table.sort(results, function(a, b) return a.row < b.row end)
	return results
end

--- Load env, build status_id and version_id lookup tables.
---@return table|nil, table|nil, table|nil, string|nil  env, status_id_by_name, version_id_by_name, err
local function prepare_issue_context()
	local env = load_env()

	local status_id_by_name = {}
	for _, s in ipairs(env.open_statuses or {}) do
		status_id_by_name[s.name] = s.id
	end
	for _, s in ipairs(env.closed_statuses or {}) do
		status_id_by_name[s.name] = s.id
	end

	local versions, err = M.versions()
	if not versions then
		return nil, nil, nil, err
	end
	local version_id_by_name = {}
	for _, v in ipairs(versions) do
		version_id_by_name[v.name] = v.id
	end

	return env, status_id_by_name, version_id_by_name, nil
end

--- Build common issue payload fields (subject, status_id, fixed_version_id).
---@param item {title: string, status: string|nil, version: string|nil}
---@param status_id_by_name table
---@param version_id_by_name table
---@return table
local function build_issue_fields(item, status_id_by_name, version_id_by_name)
	local fields = { subject = item.title }
	fields.status_id = status_id_by_name[item.status]
	if item.version ~= "Archive" then
		fields.fixed_version_id = version_id_by_name[item.version]
	end
	return fields
end

--- Update a Redmine issue's subject, status and version from a todo item.
--- Skips fixed_version_id when version is "Archive".
---@param item {issue: string, title: string, version: string, status: string|nil}
---@return nil, string|nil
function M.update_issue(item)
	local issue_id = item.issue and item.issue:match("%d+")
	if not issue_id then
		return nil, "missing issue id"
	end

	local env, status_id_by_name, version_id_by_name, err = prepare_issue_context()
	if not env then
		return nil, err
	end

	local base_url = env.base_url or error("BASE_URL not found in .env")
	local payload = { issue = build_issue_fields(item, status_id_by_name, version_id_by_name) }
	return redmine_put(base_url .. "issues/" .. issue_id .. ".json", env.token, payload)
end

--- Create a new Redmine issue from a todo item that has no @issue tag yet.
--- item.issue must be nil; item.version must match a known version.
---@param item {title: string, version: string, status: string|nil, issue: nil}
---@return table|nil, string|nil  decoded response, err
function M.create_issue(item)
	if item.issue ~= nil then
		return nil, "item already has an issue id: " .. tostring(item.issue)
	end

	local env, status_id_by_name, version_id_by_name, err = prepare_issue_context()
	if not env then
		return nil, err
	end

	local project_url = env.project_url or error("PROJECT_URL not found in .env")

	if not version_id_by_name[item.version] then
		return nil, "unknown version: " .. tostring(item.version)
	end

	local fields = build_issue_fields(item, status_id_by_name, version_id_by_name)
	fields.assigned_to_id = "me"
	fields.tracker = { id = 2, name = "Tarefa" }
	fields.custom_fields = { { id = 31, name = "Tipo de manutenção", value = "Projeto" } }

	return redmine_post(project_url .. "issues.json", env.token, { issue = fields })
end

--- Update or create the Redmine issue for the todo item on the current cursor line.
--- Creates a new issue when the item has no @issue tag and adds @issue(#id) to the buffer.
---@return nil, string|nil
function M.update_issue_under_cursor()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local items = M.enumerate_issues(vim.api.nvim_buf_get_name(0))
	for _, item in ipairs(items) do
		if item.row == row then
			if item.issue == nil then
				local response, err = M.create_issue(item)
				if not response then
					return nil, err
				end
				local new_id = response.issue and response.issue.id
				if new_id then
					require("checkmate").add_metadata("issue", "#" .. new_id)
				end
				return nil, nil
			else
				return M.update_issue(item)
			end
		end
	end
	return nil, "no issue found on current line"
end

return M

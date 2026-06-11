local M = {}

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
---@return table|nil, string|nil  decoded body or nil, error message
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

--- Build a sorted list of {row, version} from ATX headings in the buffer using treesitter
---@param bufnr integer
---@return {row: integer, version: string}[]
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

--- Return all open issues for the configured Redmine project.
---@return {id: integer, subject: string, status: string|nil, version: string|nil, assigned_to: string|nil}[]|nil, string|nil
function M.open_issues()
	local env = load_env()
	local project_url = env.project_url or error("PROJECT_URL not found in .env")
	local token = env.token or error("TOKEN not found in .env")

	local all_issues = {}
	local offset = 0
	local limit = 100

	while true do
		local url = project_url
			.. "issues.json?status_id=open&assigned_to_id=me&limit="
			.. limit
			.. "&offset="
			.. offset
		local data, err = redmine_get(url, token)
		if not data then
			return nil, err
		end

		local issues = data.issues or {}
		for _, iss in ipairs(issues) do
			all_issues[#all_issues + 1] = {
				id = iss.id,
				subject = iss.subject,
				status = iss.status and iss.status.name or nil,
				version = iss.fixed_version and iss.fixed_version.name or nil,
				assigned_to = iss.assigned_to and iss.assigned_to.name or nil,
			}
		end

		if offset + #issues >= (data.total_count or 0) then
			break
		end
		offset = offset + limit
	end

	return all_issues, nil
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

	local status_marker = {
		["In Progress"] = "[.]",
	}

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

--- Sync open issues to todo.md in the nvim config root.
--- Creates a new jj change, then overwrites todo.md with the report.
---@return nil, string|nil
function M.load_todo()
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
	return nil, nil
end

return M

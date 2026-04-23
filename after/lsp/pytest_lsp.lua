-- https://github.com/pytest-dev/pytest-language-server
---@type vim.lsp.Config
return {
	cmd = { "pytest-language-server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "pytest.ini", ".git" },
}

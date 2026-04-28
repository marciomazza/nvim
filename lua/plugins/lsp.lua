vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		vim.keymap.set("n", "gd", function()
			local pytest_clients = vim.lsp.get_clients({ bufnr = 0, name = "pytest_lsp" })
			if #pytest_clients == 0 then
				vim.lsp.buf.definition()
				return
			end
			local client = pytest_clients[1]
			local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
			client:request("textDocument/definition", params, function(err, result)
				local has_result = not err
					and result
					and type(result) == "table"
					and (result.uri ~= nil or #result > 0)
				if has_result then
					local loc = vim.islist(result) and result[1] or result
					vim.lsp.util.show_document(loc, client.offset_encoding, { focus = true })
				else
					vim.lsp.buf.definition({ filter = function(c) return c.name ~= "pytest_lsp" end })
				end
			end, 0)
		end, { buffer = ev.buf, desc = "Go to definition" })
	end,
})

vim.lsp.enable("pytest_lsp")

return {
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
				"stylua",
				"ruff",
				"pyrefly",
				"lua_ls",
				"tombi",
				"tailwindcss",
				"cssls",
				"djlsp",
				"ts_ls",
				"oxfmt",
				"oxlint",
				"htmx",
			},
		},
	},
}

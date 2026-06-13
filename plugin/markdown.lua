pack_changed_hook(
  "markdown-preview.nvim",
  function(ev) vim.system({ "npm", "install" }, { cwd = ev.data.path .. "/app" }) end
)

vim.pack.add({
  "https://github.com/iamcco/markdown-preview.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

vim.g.mkdp_filetypes = { "markdown" }
vim.keymap.set("n", "<leader>mp", vim.cmd.MarkdownPreview, { desc = "Markdown Preview" })

require("render-markdown").setup({
  bullet = { enabled = false },
  anti_conceal = {
    enabled = false,
    ignore = {
      code_background = true,
      sign = true,
      check_icon = true,
      check_scope = true,
    },
  },
  -- render_modes = true,
  checkbox = {
    checked = { scope_highlight = "@markup.strikethrough" },
    position = "overlay",
    custom = {
      todo = {
        raw = "[-]",
        rendered = "󰓎 ",
        highlight = "DiagnosticWarn",
        scope_highlight = "DiagnosticWarn",
      },
    },
  },
})

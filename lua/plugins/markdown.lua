return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    keys = { { "<leader>mp", vim.cmd.MarkdownPreview, desc = "Markdown Preview" } },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
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
    },
  },
}

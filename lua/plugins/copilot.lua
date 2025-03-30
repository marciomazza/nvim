return {
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_filetypes = { ["*"] = true }
      vim.g.copilot_context_aware = true
    end
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      model = "claude-3.7-sonnet",
      window = { width = 90 },
      auto_insert_mode = false,
    },
    keys = {
      {
        "<F2>",
        function() require("CopilotChat").toggle() end,
        desc = "Toggle CopilotChat",
        mode = { "n", "v" }
      },
    },
  }
}

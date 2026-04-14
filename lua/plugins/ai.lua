return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = "<Tab>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-e>",
        },
      },
      panel = { enabled = false },
    },
  },
}

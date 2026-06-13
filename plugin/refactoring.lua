vim.pack.add({
  "https://github.com/lewis6991/async.nvim",
  "https://github.com/ThePrimeagen/refactoring.nvim",
})

local refactoring = require("refactoring")
for _, map in ipairs({
  { key = "re", method = "extract_func", desc = "Extract Function" },
  { key = "rE", method = "extract_func_to_file", desc = "Extract Function To File" },
  { key = "rv", method = "extract_var", desc = "Extract Variable" },
  { key = "ri", method = "inline_var", desc = "Inline Variable" },
  { key = "rI", method = "inline_func", desc = "Inline function" },
  { key = "rs", method = "select_refactor", desc = "Select refactor" },
}) do
  vim.keymap.set(
    { "n", "x" },
    "<leader>" .. map.key,
    function() return refactoring[map.method]() end,
    { desc = map.desc, expr = true }
  )
end

-- `_` is the default textobject for "current line"
vim.keymap.set(
  "n",
  "<leader>ree",
  function() return refactoring.extract_func() .. "_" end,
  { desc = "Extract Function (line)", expr = true }
)

-- `_` is the default textobject for "current line"
vim.keymap.set(
  "n",
  "<leader>rvv",
  function() return refactoring.extract_var() .. "_" end,
  { desc = "Extract Variable (line)", expr = true }
)

local debug = require("refactoring.debug")

-- `iw` is the builtin textobject for "in word". You can use any other textobject or even create the keymap without any textobject if you prefer to provide one yourself each time that you use the keymap
vim.keymap.set(
  { "x", "n" },
  "<leader>pv",
  function() return debug.print_var({ output_location = "below" }) .. "iw" end,
  { desc = "Debug print var below", expr = true }
)

-- `iw` is the builtin textobject for "in word". You can use any other textobject or even create the keymap without any textobject if you prefer to provide one yourself each time that you use the keymap
vim.keymap.set(
  { "x", "n" },
  "<leader>pV",
  function() return debug.print_var({ output_location = "above" }) .. "iw" end,
  { desc = "Debug print var above", expr = true }
)

vim.keymap.set(
  { "x", "n" },
  "<leader>pe",
  function() return debug.print_exp({ output_location = "below" }) end,
  { desc = "Debug print exp below", expr = true }
)
-- `_` is the default textobject for "current line"
vim.keymap.set(
  "n",
  "<leader>pee",
  function() return debug.print_exp({ output_location = "below" }) .. "_" end,
  { desc = "Debug print exp below", expr = true }
)

vim.keymap.set(
  { "x", "n" },
  "<leader>pE",
  function() return debug.print_exp({ output_location = "above" }) end,
  { desc = "Debug print exp above", expr = true }
)
-- `_` is the default textobject for "current line"
vim.keymap.set(
  "n",
  "<leader>pEE",
  function() return debug.print_exp({ output_location = "above" }) .. "_" end,
  { desc = "Debug print exp above", expr = true }
)

vim.keymap.set(
  "n",
  "<leader>pP",
  function() return debug.print_loc({ output_location = "above" }) end,
  { desc = "Debug print location", expr = true }
)
vim.keymap.set(
  "n",
  "<leader>pp",
  function() return debug.print_loc({ output_location = "below" }) end,
  { desc = "Debug print location", expr = true }
)

vim.keymap.set({ "x", "n" }, "<leader>pc", function()
  -- `ag` is a custom textobject that selects the whole buffer. It's provided by plugins like `mini.ai` (requires manual configuration using `MiniExtra.gen_ai_spec.buffer()`).
  -- return debug.cleanup { restore_view = true } .. "ag"

  -- this keymap doesn't select any textobject by default, so you need to provide one each time you use it.
  return debug.cleanup({ restore_view = true })
end, { desc = "Debug print clean", expr = true, remap = true })

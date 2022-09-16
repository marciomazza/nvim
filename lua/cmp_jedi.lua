--- custom jedi source for nvim-cmp

-- read python code for jedi completion function
local current_dir = debug.getinfo(1).source:match("@(.*/)")
vim.cmd(string.format('py3file %s/cmp_jedi.py', current_dir))

local function get_completions()
   return vim.fn.py3eval("get_jedi_completions()")
end

local CompletionItemKind = require('cmp.types').lsp.CompletionItemKind

-- based on pappasam/jedi-language-server ... jedi_language_server/type_map.py
local _JEDI_COMPLETION_TYPE_MAP = {
    module = CompletionItemKind.Module,
    class = CompletionItemKind.Class,
    instance = CompletionItemKind.Variable,
    ['function'] = CompletionItemKind.Function,
    param = CompletionItemKind.Variable,
    path = CompletionItemKind.File,
    keyword = CompletionItemKind.Keyword,
    property = CompletionItemKind.Property,
    statement = CompletionItemKind.Variable,
}

local function get_lsp_completion_type(jedi_type)
  return _JEDI_COMPLETION_TYPE_MAP[jedi_type] or CompletionItemKind.Text
end

-- nvim-cmp custom source ----------------------------------------------
local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

function source:is_available()
  return vim.bo.filetype == 'python'
end

function source:complete(params, callback)
  completions = get_completions()
  items = {}
  for _, completion in ipairs(completions) do
    table.insert(items, {
      label = completion.name,
      kind = get_lsp_completion_type(completion.type),
    })
  end
  callback(items)
end

require('cmp').register_source('jedi', source.new())

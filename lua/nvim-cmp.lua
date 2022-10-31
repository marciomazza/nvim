return {
  'hrsh7th/nvim-cmp',
  requires = {
    'onsails/lspkind.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
  },
  config = function()
    vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
    local cmp = require('cmp')
    cmp.setup {
      mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        -- Accept currently selected item.
        -- Set `select` to `false` to only confirm explicitly selected items.
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'nvim_lua' },
      },
      formatting = { format = require('lspkind').cmp_format() },
    }
  end
}

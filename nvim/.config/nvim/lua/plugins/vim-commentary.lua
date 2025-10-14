return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup({
      -- Enable treesitter integration for better context-aware commenting
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    })
  end,
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring'
  }
}

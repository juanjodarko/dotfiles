require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'comment',
    'css',
    'dockerfile',
    'javascript',
    'lua',
    'markdown',
    'ruby',
    'rust',
    'typescript',
    'vue'
  },
  highlight = {
    enable = true,
    disable = { 'NvimTree' },
    additional_vim_regex_highlighting = true,
  },
  context_commentstring = {
    enable = true,
  },
})

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
    'typescript'
  },
  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
    disable = { 'NvimTree' },
    additional_vim_regex_highlighting = false,
  },
  context_commentstring = {
    enable = true,
  },
})

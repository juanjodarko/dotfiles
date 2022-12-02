local ls = require('luasnip')

-- require("luasnip.loaders.from_snipmate").lazy_load()

ls.config.set_config({
  history = true,
  updateevents = 'TextChanged,TextChangedI',
})

ls.add_snippets('typescript', {
  ls.parser.parse_snippet('import', "import $1 from '$0'"),
})


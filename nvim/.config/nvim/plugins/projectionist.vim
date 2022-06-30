Plug 'tpope/vim-projectionist'

let g:projectionist_heuristics = {
\   "app/models/*.rb": {
\     "command": "model",
\     "affinity": "model",
\     "test": "spec/models/{}_spec.rb",
\     "related": "app/models/{}.rb",
\     "template": "class {camelcase|capitalize|colons} < ActiveModel\nend"
\   }
\ }

Plug 'tpope/vim-projectionist'

let g:projectionist_heuristics = {
    \   "*": {
    \     "start": "rails s -b 0.0.0.0",
    \     "console": "rails c",
    \   },
    \   "app/**/*_controller.rb": {
    \     "type": "source",
    \     "alternate": "spec/controllers/{}_controller_spec.rb"
    \   },
    \   "app/**/Models/*.php": {
    \     "type": "source",
    \     "alternate": [
    \       "tests/Unit/{dirname}/Models/{basename}Test.php",
    \       "tests/Unit/{dirname}/{basename}Test.php",
    \     ],
    \   },
    \   "app/**/Listeners/*.php": {
    \     "type": "source",
    \     "alternate": "tests/Unit/{dirname}/Listeners/{basename}Test.php",
    \   },
    \   "app/*.php": {
    \     "type": "source",
    \     "alternate": [
    \       "tests/Unit/{}Test.php",
    \       "tests/Feature/{}Test.php",
    \     ]
    \   },
    \   "tests/Feature/*Test.php": {
    \     "type": "test",
    \     "alternate": "app/{}.php",
    \   },
    \   "tests/Unit/*Test.php": {
    \     "type": "test",
    \     "alternate": [
    \       "app/{}.php",
    \       "app/Models/{}.php",
    \     ],
    \   },
    \ }

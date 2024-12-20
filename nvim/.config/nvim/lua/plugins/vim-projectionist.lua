return {
    'tpope/vim-projectionist',
    dependencies = {
        'tpope/vim-dispatch'
    },
    config = function()
        vim.g.projectionist_heuristics = {
            ["*"] = {
                ["app/models/*.rb"] = {
                    alternate = "spec/models/{}_spec.rb"
                },
                ["app/services/*.rb"] = {
                    alternate = "spec/services/{}_spec.rb"
                },
                ["spec/models/*_spec.rb"] = {
                    alternate = "app/models/{}.rb"
                },
                ["spec/services/*_spec.rb"] = {
                    alternate = "app/services/{}.rb"
                }
            }
        }
    end
}

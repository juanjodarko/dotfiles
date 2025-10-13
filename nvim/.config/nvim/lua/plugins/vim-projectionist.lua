return {
    'tpope/vim-projectionist',
    dependencies = {
        'tpope/vim-dispatch'
    },
    config = function()
        vim.g.projectionist_heuristics = {
            -- ==========================================
            -- RAILS PATTERNS (works with vim-rails)
            -- ==========================================
            ["config/application.rb|config/environment.rb"] = {
                -- Controllers
                ["app/controllers/*_controller.rb"] = {
                    type = "controller",
                    alternate = "spec/requests/{}_spec.rb",
                    related = "app/views/{}",
                },
                ["spec/requests/*_spec.rb"] = {
                    type = "request",
                    alternate = "app/controllers/{}_controller.rb",
                },

                -- Models
                ["app/models/*.rb"] = {
                    type = "model",
                    alternate = "spec/models/{}_spec.rb",
                    related = "db/schema.rb",
                },
                ["spec/models/*_spec.rb"] = {
                    type = "spec",
                    alternate = "app/models/{}.rb",
                },

                -- Services
                ["app/services/*.rb"] = {
                    type = "service",
                    alternate = "spec/services/{}_spec.rb",
                },
                ["spec/services/*_spec.rb"] = {
                    type = "spec",
                    alternate = "app/services/{}.rb",
                },

                -- Jobs
                ["app/jobs/*_job.rb"] = {
                    type = "job",
                    alternate = "spec/jobs/{}_job_spec.rb",
                },
                ["spec/jobs/*_job_spec.rb"] = {
                    type = "spec",
                    alternate = "app/jobs/{}_job.rb",
                },

                -- Mailers
                ["app/mailers/*_mailer.rb"] = {
                    type = "mailer",
                    alternate = "spec/mailers/{}_mailer_spec.rb",
                    related = "app/views/{}_mailer",
                },
                ["spec/mailers/*_mailer_spec.rb"] = {
                    type = "spec",
                    alternate = "app/mailers/{}_mailer.rb",
                },

                -- Helpers
                ["app/helpers/*_helper.rb"] = {
                    type = "helper",
                    alternate = "spec/helpers/{}_helper_spec.rb",
                },
                ["spec/helpers/*_helper_spec.rb"] = {
                    type = "spec",
                    alternate = "app/helpers/{}_helper.rb",
                },

                -- Channels (Action Cable)
                ["app/channels/*_channel.rb"] = {
                    type = "channel",
                    alternate = "spec/channels/{}_channel_spec.rb",
                },
                ["spec/channels/*_channel_spec.rb"] = {
                    type = "spec",
                    alternate = "app/channels/{}_channel.rb",
                },

                -- Policies (Pundit)
                ["app/policies/*_policy.rb"] = {
                    type = "policy",
                    alternate = "spec/policies/{}_policy_spec.rb",
                },
                ["spec/policies/*_policy_spec.rb"] = {
                    type = "spec",
                    alternate = "app/policies/{}_policy.rb",
                },

                -- Serializers
                ["app/serializers/*_serializer.rb"] = {
                    type = "serializer",
                    alternate = "spec/serializers/{}_serializer_spec.rb",
                },
                ["spec/serializers/*_serializer_spec.rb"] = {
                    type = "spec",
                    alternate = "app/serializers/{}_serializer.rb",
                },

                -- Model Concerns
                ["app/models/concerns/*.rb"] = {
                    type = "concern",
                    alternate = "spec/models/concerns/{}_spec.rb",
                },
                ["spec/models/concerns/*_spec.rb"] = {
                    type = "spec",
                    alternate = "app/models/concerns/{}.rb",
                },

                -- Controller Concerns
                ["app/controllers/concerns/*.rb"] = {
                    type = "concern",
                    alternate = "spec/controllers/concerns/{}_spec.rb",
                },
                ["spec/controllers/concerns/*_spec.rb"] = {
                    type = "spec",
                    alternate = "app/controllers/concerns/{}.rb",
                },

                -- Lib files
                ["lib/*.rb"] = {
                    type = "lib",
                    alternate = "spec/lib/{}_spec.rb",
                },
                ["spec/lib/*_spec.rb"] = {
                    type = "spec",
                    alternate = "lib/{}.rb",
                },

                -- ==========================================
                -- GRAPHQL PATTERNS
                -- ==========================================
                ["app/graphql/types/*_type.rb"] = {
                    type = "graphql_type",
                    alternate = "spec/graphql/types/{}_type_spec.rb",
                },
                ["spec/graphql/types/*_type_spec.rb"] = {
                    type = "spec",
                    alternate = "app/graphql/types/{}_type.rb",
                },

                ["app/graphql/mutations/*.rb"] = {
                    type = "mutation",
                    alternate = "spec/graphql/mutations/{}_spec.rb",
                },
                ["spec/graphql/mutations/*_spec.rb"] = {
                    type = "spec",
                    alternate = "app/graphql/mutations/{}.rb",
                },

                ["app/graphql/resolvers/*.rb"] = {
                    type = "resolver",
                    alternate = "spec/graphql/resolvers/{}_spec.rb",
                },
                ["spec/graphql/resolvers/*_spec.rb"] = {
                    type = "spec",
                    alternate = "app/graphql/resolvers/{}.rb",
                },
            },

            -- ==========================================
            -- REACT/TYPESCRIPT PATTERNS (for monorepos)
            -- ==========================================
            ["package.json"] = {
                -- React Components (TypeScript)
                ["src/components/*/*.tsx"] = {
                    type = "component",
                    alternate = "src/components/{}/{}.test.tsx",
                },
                ["src/components/*/*.test.tsx"] = {
                    type = "test",
                    alternate = "src/components/{}/{}.tsx",
                },

                -- React Components (flat structure)
                ["src/components/*.tsx"] = {
                    type = "component",
                    alternate = "src/components/{}.test.tsx",
                },
                ["src/components/*.test.tsx"] = {
                    type = "test",
                    alternate = "src/components/{}.tsx",
                },

                -- Hooks
                ["src/hooks/*.ts"] = {
                    type = "hook",
                    alternate = "src/hooks/{}.test.ts",
                },
                ["src/hooks/*.test.ts"] = {
                    type = "test",
                    alternate = "src/hooks/{}.ts",
                },

                -- Utils
                ["src/utils/*.ts"] = {
                    type = "util",
                    alternate = "src/utils/{}.test.ts",
                },
                ["src/utils/*.test.ts"] = {
                    type = "test",
                    alternate = "src/utils/{}.ts",
                },

                -- Pages/Routes
                ["src/pages/*.tsx"] = {
                    type = "page",
                    alternate = "src/pages/{}.test.tsx",
                },
                ["src/pages/*.test.tsx"] = {
                    type = "test",
                    alternate = "src/pages/{}.tsx",
                },

                -- Context/Providers
                ["src/context/*.tsx"] = {
                    type = "context",
                    alternate = "src/context/{}.test.tsx",
                },
                ["src/context/*.test.tsx"] = {
                    type = "test",
                    alternate = "src/context/{}.tsx",
                },

                -- Services/API
                ["src/services/*.ts"] = {
                    type = "service",
                    alternate = "src/services/{}.test.ts",
                },
                ["src/services/*.test.ts"] = {
                    type = "test",
                    alternate = "src/services/{}.ts",
                },

                -- Stores (Redux/Zustand)
                ["src/store/*.ts"] = {
                    type = "store",
                    alternate = "src/store/{}.test.ts",
                },
                ["src/store/*.test.ts"] = {
                    type = "test",
                    alternate = "src/store/{}.ts",
                },
            },
        }

        -- Standard keymap helper
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
        end

        -- TDD Navigation Keybindings
        map('n', '<leader>a', ':A<CR>', "Alternate file (test ↔ impl)")
        map('n', '<leader>av', ':AV<CR>', "Alternate file (vertical split)")
        map('n', '<leader>as', ':AS<CR>', "Alternate file (horizontal split)")
        map('n', '<leader>at', ':AT<CR>', "Alternate file (new tab)")
    end
}

return {
    'tpope/vim-projectionist',
    dependencies = {
        'tpope/vim-dispatch'
    },
    config = function()
        -- NOTE: Rails alternate navigation (:A between app/* and spec/*) is handled
        -- by vim-rails, which auto-detects rspec vs minitest and request vs controller
        -- specs. Do NOT re-declare Rails projections here or they will fight vim-rails.
        -- This file owns ONLY the JS/TS side (Next.js / Vercel / React / Node).
        --
        -- projectionist `*` matches across directory separators, so a single glob
        -- handles nested files. `{}` = full match, `{dirname}`/`{basename}` = parts.
        -- Alternates are tried in order; :A opens the first that exists (and offers to
        -- create the first entry when none exist).
        vim.g.projectionist_heuristics = {
            ["package.json"] = {
                -- React/Next components (co-located tests preferred, then __tests__)
                ["*.tsx"] = {
                    type = "source",
                    alternate = {
                        "{}.test.tsx",
                        "{}.spec.tsx",
                        "{dirname}/__tests__/{basename}.test.tsx",
                        "{dirname}/__tests__/{basename}.spec.tsx",
                    },
                },
                ["*.test.tsx"] = { type = "test", alternate = "{}.tsx" },
                ["*.spec.tsx"] = { type = "test", alternate = "{}.tsx" },

                -- Plain TS (hooks, utils, services, stores, route handlers, lib)
                ["*.ts"] = {
                    type = "source",
                    alternate = {
                        "{}.test.ts",
                        "{}.spec.ts",
                        "{dirname}/__tests__/{basename}.test.ts",
                        "{dirname}/__tests__/{basename}.spec.ts",
                    },
                },
                ["*.test.ts"] = { type = "test", alternate = "{}.ts" },
                ["*.spec.ts"] = { type = "test", alternate = "{}.ts" },

                -- JS / JSX fallbacks (non-TS Next/Node projects)
                ["*.jsx"] = {
                    type = "source",
                    alternate = {
                        "{}.test.jsx",
                        "{}.spec.jsx",
                        "{dirname}/__tests__/{basename}.test.jsx",
                    },
                },
                ["*.test.jsx"] = { type = "test", alternate = "{}.jsx" },
                ["*.spec.jsx"] = { type = "test", alternate = "{}.jsx" },

                ["*.js"] = {
                    type = "source",
                    alternate = {
                        "{}.test.js",
                        "{}.spec.js",
                        "{dirname}/__tests__/{basename}.test.js",
                    },
                },
                ["*.test.js"] = { type = "test", alternate = "{}.js" },
                ["*.spec.js"] = { type = "test", alternate = "{}.js" },
            },
        }

        -- Standard keymap helper
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
        end

        -- TDD Navigation Keybindings (works for both vim-rails and the JS projections above)
        map('n', '<leader>a', ':A<CR>', "Alternate file (test ↔ impl)")
        map('n', '<leader>av', ':AV<CR>', "Alternate file (vertical split)")
        map('n', '<leader>as', ':AS<CR>', "Alternate file (horizontal split)")
        map('n', '<leader>at', ':AT<CR>', "Alternate file (new tab)")
    end
}

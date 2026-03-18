-- Intelligent, context-aware LSP configuration (Neovim 0.11+ native API)
local project_utils = require('user.project_utils')

-- Add cmp_nvim_lsp capabilities to all LSP servers
vim.lsp.config('*', {
    capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
    ),
})

-- Enhanced LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        -- Standard keymap helper
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc, silent = true })
        end

        -- LSP navigation
        map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', "Hover documentation")
        map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', "Go to definition")
        map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', "Go to declaration")
        map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', "Go to implementation")
        map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', "Go to type definition")
        map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', "Show references")
        map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', "Signature help")

        -- LSP actions
        map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', "Rename symbol")
        map({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', "Format code")
        map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', "Code actions")

        -- Workspace management
        map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', "Add workspace folder")
        map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', "Remove workspace folder")
        map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', "List workspace folders")
    end,
})

-- Helper function to setup LSP server with project-specific overrides
local function setup_lsp_server(server_name, config)
    if project_utils.is_lsp_disabled(server_name) then
        return
    end

    local project_overrides = project_utils.get_lsp_overrides(server_name)
    config = vim.tbl_deep_extend('force', config, project_overrides)

    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
end

-- LSP server configurations with intelligent project detection
local function setup_lsp_servers()
    local project_config = project_utils.get_project_config()

    -- Always setup Lua LSP for Neovim config
    setup_lsp_server('lua_ls', {
        settings = {
            Lua = {
                runtime = { version = 'LuaJIT' },
                diagnostics = { globals = { 'vim' } },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = { enable = false },
            },
        },
    })

    -- Ruby & Rails LSP Configuration
    if project_config.is_ruby or project_config.is_rails then
        -- Solargraph (primary Ruby LSP)
        setup_lsp_server('solargraph', {
            root_markers = { "Gemfile", ".git" },
            settings = {
                solargraph = {
                    diagnostics = true,
                    completion = true,
                    hover = true,
                    formatting = false, -- Use standardrb for formatting
                    symbols = true,
                    definitions = true,
                    rename = true,
                    references = true,
                    folding = true,
                }
            }
        })

        -- Ruby LS (alternative, faster Ruby LSP)
        if vim.fn.executable('ruby-lsp') == 1 then
            setup_lsp_server('ruby_lsp', {
                root_markers = { "Gemfile", ".git" },
                cmd = { "ruby-lsp" },
                init_options = {
                    enabledFeatures = {
                        "documentHighlights",
                        "documentSymbols",
                        "foldingRanges",
                        "selectionRanges",
                        "semanticHighlighting",
                        "formatting",
                        "codeActions",
                    },
                },
            })
        end

        -- Standardrb for Ruby formatting/linting (context-aware)
        local standardrb_cmd = project_utils.find_executable('standardrb')
        if standardrb_cmd then
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "ruby",
                group = vim.api.nvim_create_augroup("RubyLSP", { clear = true }),
                callback = function()
                    vim.lsp.start({
                        name = "standardrb",
                        cmd = { standardrb_cmd, "--lsp" },
                        root_dir = vim.fs.root(0, { "Gemfile", ".git" }),
                    })
                end,
            })
        end

        -- Rails-specific enhancements
        if project_config.is_rails then
            -- Additional Rails-specific setup can go here
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "ruby", "eruby" },
                callback = function()
                    -- Rails-specific settings
                    vim.bo.iskeyword = vim.bo.iskeyword .. "?,!"
                end
            })
        end
    end

    -- JavaScript/TypeScript/React/Node.js LSP Configuration
    if project_config.is_javascript or project_config.is_typescript or project_config.is_nodejs or project_config.is_react then
        -- Custom root_dir for monorepos (prioritizes workspace root)
        local function get_typescript_root(bufnr, on_dir)
            -- For monorepos, use workspace root to avoid multiple LSP instances
            if project_config.is_monorepo then
                on_dir(project_config.monorepo_root)
                return
            end

            -- For regular projects, find nearest package.json or tsconfig.json
            local root = vim.fs.root(bufnr, { "tsconfig.json", "package.json", ".git" })
            if root then on_dir(root) end
        end

        -- TypeScript/JavaScript Server
        setup_lsp_server('ts_ls', {
            root_dir = get_typescript_root,
            single_file_support = false,  -- Prevent LSP from attaching to random files
            settings = {
                typescript = {
                    preferences = {
                        includePackageJsonAutoImports = "auto",
                    },
                    -- Enable workspace support for monorepos
                    tsserver = {
                        maxTsServerMemory = 8192,  -- Increase for large monorepos
                    },
                },
                javascript = {
                    preferences = {
                        includePackageJsonAutoImports = "auto",
                    },
                },
            },
            on_attach = function(client, bufnr)
                -- Disable ts_ls formatting in favor of prettier
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end,
        })

        -- Custom root_dir for ESLint in monorepos
        local function get_eslint_root(bufnr, on_dir)
            -- For monorepos, use workspace root for consistent config
            if project_config.is_monorepo then
                on_dir(project_config.monorepo_root)
                return
            end

            -- For regular projects, find nearest eslint config
            local root = vim.fs.root(bufnr, {
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.json",
                "eslint.config.js",
                "package.json",
            })
            if root then on_dir(root) end
        end

        -- ESLint LSP
        setup_lsp_server('eslint', {
            root_dir = get_eslint_root,
            settings = {
                codeAction = {
                    disableRuleComment = {
                        enable = true,
                        location = "separateLine"
                    },
                    showDocumentation = {
                        enable = true
                    }
                },
                codeActionOnSave = {
                    enable = false,
                    mode = "all"
                },
                experimental = {
                    useFlatConfig = false
                },
                format = true,
                nodePath = "",
                onIgnoredFiles = "off",
                packageManager = project_config.is_monorepo and "pnpm" or "npm",
                problems = {
                    shortenToSingleLine = false
                },
                quiet = false,
                rulesCustomizations = {},
                run = "onType",
                useESLintClass = false,
                validate = "on",
                workingDirectory = {
                    -- Use auto mode for monorepos (uses nearest package.json as working dir)
                    mode = project_config.is_monorepo and "auto" or "location"
                }
            }
        })

        -- HTML LSP (for React JSX)
        setup_lsp_server('html', {
            filetypes = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact" }
        })

        -- CSS LSP
        setup_lsp_server('cssls', {
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore"
                    }
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore"
                    }
                }
            }
        })

        -- Tailwind CSS LSP (if tailwind.config.js exists)
        if vim.fn.glob(project_config.root_dir .. "/tailwind.config.*") ~= "" then
            setup_lsp_server('tailwindcss', {
                root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json" },
            })
        end

        -- Emmet LSP for HTML/JSX
        setup_lsp_server('emmet_ls', {
            filetypes = {
                "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact"
            }
        })
    end

    -- Go LSP Configuration
    if project_config.is_go then
        setup_lsp_server('gopls', {
            root_markers = { "go.mod", ".git" },
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                    usePlaceholders = true,
                    completionDocumentation = true,
                    semanticTokens = true,
                },
            },
        })
    end

    -- Elixir LSP Configuration
    if project_config.is_elixir then
        setup_lsp_server('elixirls', {
            cmd = { "elixir-ls" },
            root_markers = { "mix.exs", ".git" },
            settings = {
                elixirLS = {
                    dialyzerEnabled = false,
                    fetchDeps = false,
                }
            }
        })
    end

    -- C++ LSP Configuration
    if project_config.is_cpp then
        setup_lsp_server('clangd', {
            root_markers = { "CMakeLists.txt", "compile_commands.json", ".git" },
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        })
    end

    -- GraphQL LSP Configuration
    if project_config.is_graphql or project_config.is_javascript or project_config.is_typescript or project_config.is_react then
        setup_lsp_server('graphql', {
            root_markers = {
                ".graphqlrc",
                ".graphqlrc.yml",
                ".graphqlrc.yaml",
                ".graphqlrc.json",
                "graphql.config.js",
                "graphql.config.ts",
                "package.json",
                ".git",
            },
            filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
        })
    end

    -- Python LSP Configuration
    if project_config.is_python then
        setup_lsp_server('pyright', {
            root_markers = {
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                "pyrightconfig.json",
                ".git",
            },
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                        typeCheckingMode = "basic",
                    },
                },
            },
        })
    end

    -- Rust LSP Configuration
    if project_config.is_rust then
        setup_lsp_server('rust_analyzer', {
            root_markers = { "Cargo.toml", "rust-project.json", ".git" },
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                    },
                    checkOnSave = {
                        command = "clippy",
                    },
                    procMacro = {
                        enable = true,
                    },
                },
            },
        })
    end

    -- Additional universal LSP servers
    setup_lsp_server('jsonls', {
        settings = {
            json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
            },
        },
    })

    setup_lsp_server('yamlls', {
        settings = {
            yaml = {
                schemaStore = {
                    enable = false,
                    url = "",
                },
                schemas = require('schemastore').yaml.schemas(),
            },
        },
    })

    setup_lsp_server('bashls', {})
    setup_lsp_server('dockerls', {})
    setup_lsp_server('marksman', {})
end

-- Setup all LSP servers
setup_lsp_servers()

-- Auto-reload LSP configuration when switching projects
vim.api.nvim_create_autocmd({"DirChanged", "BufEnter"}, {
    callback = function()
        -- Only reload if we've changed to a different project
        local current_root = project_utils.get_project_root()
        if vim.g.last_project_root ~= current_root then
            vim.g.last_project_root = current_root
            -- Optionally restart LSP servers for new project context
            -- vim.cmd('LspRestart')
        end
    end,
})

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = true,
    },
    float = {
        source = true,
        border = 'rounded',
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Intelligent, context-aware LSP configuration
local lspconfig = require('lspconfig')
local project_utils = require('user.project_utils')

-- Reserve a space in the gutter to avoid layout shift
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)

-- Enhanced LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        
        -- Additional useful keybindings
        vim.keymap.set('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
        vim.keymap.set('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
        vim.keymap.set('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
    end,
})

-- Helper function to setup LSP server with project-specific overrides
local function setup_lsp_server(server_name, default_config)
    if project_utils.is_lsp_disabled(server_name) then
        return
    end
    
    local project_overrides = project_utils.get_lsp_overrides(server_name)
    local config = vim.tbl_deep_extend('force', default_config, project_overrides)
    
    lspconfig[server_name].setup(config)
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
            root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
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
            setup_lsp_server('ruby_ls', {
                root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
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
                        root_dir = lspconfig.util.root_pattern("Gemfile", ".git")(vim.fn.expand('%:p:h')),
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
        -- TypeScript/JavaScript Server
        setup_lsp_server('tsserver', {
            root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
            settings = {
                typescript = {
                    preferences = {
                        includePackageJsonAutoImports = "auto",
                    },
                },
                javascript = {
                    preferences = {
                        includePackageJsonAutoImports = "auto", 
                    },
                },
            },
            on_attach = function(client, bufnr)
                -- Disable tsserver formatting in favor of prettier
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end,
        })

        -- ESLint LSP
        setup_lsp_server('eslint', {
            root_dir = lspconfig.util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json"),
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
                packageManager = "npm",
                problems = {
                    shortenToSingleLine = false
                },
                quiet = false,
                rulesCustomizations = {},
                run = "onType",
                useESLintClass = false,
                validate = "on",
                workingDirectory = {
                    mode = "location"
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
                root_dir = lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.ts", "package.json"),
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
            root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
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
            root_dir = lspconfig.util.root_pattern("mix.exs", ".git"),
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
            root_dir = lspconfig.util.root_pattern("CMakeLists.txt", "compile_commands.json", ".git"),
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
        source = 'always',
        border = 'rounded',
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
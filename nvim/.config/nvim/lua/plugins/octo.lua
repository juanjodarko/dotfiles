return {
    'pwntester/octo.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    cmd = 'Octo',
    config = function()
        require("octo").setup({
            -- Use telescope for fuzzy finding
            picker = "telescope",

            -- PR Review Configuration
            reviews = {
                auto_show_threads = true, -- Show comment threads on cursor move
                focus = "right",          -- Focus right buffer (new code) on diff open
            },

            -- GitHub CLI settings
            default_remote = { "upstream", "origin" },
            timeout = 5000,

            -- UI Configuration
            ui = {
                use_signcolumn = true,
            },

            -- File panel for PR reviews
            file_panel = {
                size = 12,
                use_icons = true,
            },

            -- Timeline display
            timeline_indent = 2,

            -- Issue/PR sorting
            issues = {
                order_by = {
                    field = "UPDATED_AT",
                    direction = "DESC"
                }
            },
            pull_requests = {
                order_by = {
                    field = "UPDATED_AT",
                    direction = "DESC"
                },
                always_select_remote_on_create = false
            },

            -- Simplified mappings - only override essentials
            -- Most commands available via :Octo menu or which-key
            mappings = {
                review_diff = {
                    -- Essential PR review mappings
                    add_review_comment = { lhs = "<space>ca", desc = "add review comment" },
                    add_review_suggestion = { lhs = "<space>sa", desc = "add review suggestion" },
                    next_thread = { lhs = "]t", desc = "next thread" },
                    prev_thread = { lhs = "[t", desc = "prev thread" },
                    select_next_entry = { lhs = "]q", desc = "next changed file" },
                    select_prev_entry = { lhs = "[q", desc = "prev changed file" },
                },
                submit_win = {
                    approve_review = { lhs = "<C-a>", desc = "approve review" },
                    comment_review = { lhs = "<C-m>", desc = "comment review" },
                    request_changes = { lhs = "<C-r>", desc = "request changes" },
                },
                -- Use defaults for everything else
            },
        })
    end,

    -- Workflow-focused keybindings
    keys = {
        -- Main Octo menu
        { "<leader>O",   "<cmd>Octo<cr>",                                      desc = "Octo Menu" },

        -- PR Review Workflow
        {
            "<leader>opr",
            function()
                -- Find PRs where you're requested as reviewer (last 3 months)
                local three_months_ago = os.date("%Y-%m-%d", os.time() - (90 * 24 * 60 * 60))
                vim.cmd("Octo search user-review-requested:@me is:pr is:open created:>=" .. three_months_ago)
            end,
            desc = "PRs to Review"
        },

        { "<leader>opm", "<cmd>Octo search is:pr is:open author:@me<cr>",      desc = "My PRs" },
        { "<leader>opd", "<cmd>Octo pr diff<cr>",                              desc = "PR Diff" },
        { "<leader>or",  "<cmd>Octo review start<cr>",                         desc = "Start Review" },

        -- PR Management
        { "<leader>opc", "<cmd>Octo pr create<cr>",                            desc = "Create PR" },
        { "<leader>opl", "<cmd>Octo pr list<cr>",                              desc = "List PRs" },
        { "<leader>opo", "<cmd>Octo pr checkout<cr>",                          desc = "Checkout PR" },
        { "<leader>opb", "<cmd>Octo pr browser<cr>",                           desc = "Open PR in Browser" },

        -- Issue Management
        { "<leader>oil", "<cmd>Octo search is:issue is:open assignee:@me<cr>", desc = "My Issues" },
        { "<leader>oic", "<cmd>Octo issue create<cr>",                         desc = "Create Issue" },
        { "<leader>ois", "<cmd>Octo issue search<cr>",                         desc = "Search Issues" },
        { "<leader>oib", "<cmd>Octo issue browser<cr>",                        desc = "Open Issue in Browser" },

        -- Quick Actions (only in Octo buffers)
        { "<leader>oa",  "<cmd>Octo assignee add<cr>",                         desc = "Add Assignee",         ft = "octo" },
        { "<leader>ol",  "<cmd>Octo label add<cr>",                            desc = "Add Label",            ft = "octo" },
        { "<leader>oc",  "<cmd>Octo comment add<cr>",                          desc = "Add Comment",          ft = "octo" },
        { "<leader>ot",  "<cmd>Octo thread resolve<cr>",                       desc = "Resolve Thread",       ft = "octo" },
    },
}

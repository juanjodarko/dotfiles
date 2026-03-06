return {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    cmd = { 'ClaudeCode' },
    opts = {
        -- WebSocket server configuration
        -- Claude Code CLI will automatically detect and connect to Neovim
        port = 8080,

        -- Terminal window configuration
        terminal = {
            provider = "snacks",     -- Use snacks.nvim for floating windows
            snacks_win_opts = {
                position = "bottom", -- Bottom drawer style
                height = 0.4,        -- 40% of screen height
                width = 1.0,         -- Full width
                border = "rounded",  -- Rounded borders
                style = "terminal",  -- Terminal style
                wo = {
                    -- Inherit theme colors (Catppuccin)
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                }
            }
        }
    },
    keys = {
        { "<leader>c",  nil,                              desc = "AI/Claude Code" },
        { "<leader>cc", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
        { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
        { "<leader>cr", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
        { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
        { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
        { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
        { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
        {
            "<leader>cs",
            "<cmd>ClaudeCodeTreeAdd<cr>",
            desc = "Add file",
            ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
        },
        -- Diff management
        { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
        { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
}

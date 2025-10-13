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
            provider = "snacks",  -- Use snacks.nvim for floating windows
            snacks_win_opts = {
                position = "bottom",  -- Bottom drawer style
                height = 0.4,         -- 40% of screen height
                width = 1.0,          -- Full width
                border = "rounded",   -- Rounded borders
                style = "terminal",   -- Terminal style
                wo = {
                    -- Inherit theme colors (Catppuccin)
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                }
            }
        }
    },
    keys = {
        { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" }
    },
}

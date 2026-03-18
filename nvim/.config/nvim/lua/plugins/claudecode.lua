return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = { "ClaudeCode" },
  opts = {
    focus_after_send = true,
    diff_opts = {
      keep_terminal_focus = true,
    },
    terminal = {
      provider = "snacks",
      snacks_win_opts = {
        position = "bottom",
        height = 0.4,
        width = 1.0,
        border = "rounded",
        style = "terminal",
        wo = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      },
    },
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
    { "<leader>cS", "<cmd>ClaudeCodeStatus<cr>",      desc = "Claude status" },
    { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
    { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
  },
}

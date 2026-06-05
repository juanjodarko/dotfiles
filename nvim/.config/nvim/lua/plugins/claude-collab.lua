return {
  dir = vim.fn.expand("~/workspace/claude-collab"),
  name = "claude-collab",
  dependencies = {
    "coder/claudecode.nvim",
    "folke/snacks.nvim",
    "nvim-telescope/telescope.nvim",
  },
  event = "BufReadPost",
  opts = {
    debounce_ms = 100,
    flash_duration_ms = 3000,
    max_file_size = 1048576,
    conflict_style = "markers",
    notify = true,
    focus_after_prompt = false,
  },
  config = function(_, opts)
    require("claude-collab").setup(opts)
  end,
  keys = {
    { "<leader>cw", function() require("claude-collab").toggle() end, desc = "Toggle collab watcher" },
    { "<leader>ci", function() require("claude-collab").info() end, desc = "Collab info" },
    { "<leader>cj", function() require("claude-collab.sessions").pick() end, desc = "Claude: jump to session" },
    {
      "<leader>cp",
      function() require("claude-collab.prompt").open() end,
      mode = "n",
      desc = "Prompt Claude",
    },
    {
      "<leader>cp",
      function() require("claude-collab.prompt").open({ visual = true }) end,
      mode = "v",
      desc = "Prompt Claude (selection)",
    },
    {
      "<leader>cP",
      function() require("claude-collab.prompt").inline() end,
      desc = "Inline Claude prompt",
    },
  },
}

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    mode = "agentic",
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-5-20250929",
        extra_request_body = {
          max_tokens = 64000,
          temperature = 0.75,
        },
      },
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        extra_request_body = {
          timeout = 30000,
          temperature = 0.75,
          max_completion_tokens = 8192,
        },
      },
    },
    behaviour = {
      auto_set_keymaps = true,
      auto_approve_tool_permissions = true,
    },
    instructions_file = "avante.md",
  },
  keys = {
    { "<leader>aa", function() require("avante").ask() end, desc = "Avante: Ask", mode = { "n", "v" } },
    { "<leader>ae", function() require("avante").edit() end, desc = "Avante: Edit", mode = { "n", "v" } },
    { "<leader>ar", function() require("avante").refresh() end, desc = "Avante: Refresh" },
    { "<leader>az", function() require("avante.api").zen_mode() end, desc = "Avante: Zen Mode" },
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

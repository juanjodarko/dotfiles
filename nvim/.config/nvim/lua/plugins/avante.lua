return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- Provider configuration - using Claude for superior codebase understanding
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com/v1",
        model = "claude-3-5-sonnet-20241022",
        extra_request_body = {
          max_tokens = 8192,
          temperature = 0.7,
        },
      },
      -- Keep OpenAI as fallback option
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
  },
  keys = {
    { "<leader>aa", function() require("avante").ask() end, desc = "Avante: Ask", mode = { "n", "v" } },
    { "<leader>ae", function() require("avante").edit() end, desc = "Avante: Edit", mode = { "n", "v" } },
    { "<leader>ar", function() require("avante").refresh() end, desc = "Avante: Refresh" },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

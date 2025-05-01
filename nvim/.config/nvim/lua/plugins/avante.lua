return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    -- for example
    provider = "openai",
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o", -- Ensure this is the desired model
      timeout = 15000, -- Adjusted timeout for better performance
      temperature = 0.7, -- Adjusted temperature for more creative responses
      max_completion_tokens = 4096, -- Adjusted token limit for efficiency
      --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    -- Ensure these dependencies are necessary for your setup
    "echasnovski/mini.pick", -- Optional: for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- Optional: for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- Optional: autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- Optional: for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- Optional: or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- Optional: for providers='copilot'
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

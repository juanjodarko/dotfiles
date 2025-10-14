return {
  "rcarriga/nvim-notify",
  config = function()
    local notify = require("notify")

    notify.setup({
      -- Animation style (fade_in_slide_out, fade, slide, static)
      stages = "fade_in_slide_out",

      -- Default timeout for notifications
      timeout = 3000,

      -- Background colour (transparent with Catppuccin)
      background_colour = "#000000",

      -- Icons for the different levels
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },

      -- Minimum width and maximum width for notification windows
      minimum_width = 50,
      max_width = 80,
      max_height = 10,

      -- For stages that change opacity this is treated as the highlight behind the window
      -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
      -- background_colour = "Normal",

      -- Render function for notifications
      render = "default", -- "default", "minimal", "simple", "compact"

      -- Top down or bottom up rendering
      top_down = true,

      -- Show notification with FPS meter
      fps = 30,
    })

    -- Override vim.notify with nvim-notify
    vim.notify = notify
  end,
  keys = {
    {
      "<leader>nh",
      function()
        require("notify").history()
      end,
      desc = "Notification History (nvim-notify)"
    },
  },
}

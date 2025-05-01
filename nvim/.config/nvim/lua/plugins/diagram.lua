return {
  "3rd/diagram.nvim",
  dependencies = {
    "3rd/image.nvim",
  },
  config = function()
    require("diagram").setup({
      mermaid = {
        executable = "mmdc",
        format = "svg",
        theme = "default",
        background = "transparent",
      },
      integrations = {
        require("diagram.integrations.markdown"),
        require("diagram.integrations.neorg"),
      },
      renderer_options = {
        mermaid = {
          background = nil, -- nil | "transparent" | "white" | "#hex"
          theme = nil, -- nil | "default" | "dark" | "forest" | "neutral"
          scale = 1, -- nil | 1 (default) | 2  | 3 | ...
          width = nil, -- nil | 800 | 400 | ...
          height = nil, -- nil | 600 | 300 | ...
        },
        plantuml = {
          charset = nil,
        },
        d2 = {
          theme_id = nil,
          dark_theme_id = nil,
          scale = nil,
          layout = nil,
          sketch = nil,
        },
        gnuplot = {
          size = nil, -- nil | "800,600" | ...
          font = nil, -- nil | "Arial,12" | ...
          theme = nil, -- nil | "light" | "dark" | custom theme string
        },
      }
    })
  end
}

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  opts = {
    options = {
      numbers = "ordinal",
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      indicator = { icon = " " },
      buffer_close_icon = "",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      offsets = {
        {
          filetype = "NvimTree",
          text = "  Files",
          highlight = "StatusLine",
          text_align = "left",
        },
      },
      show_duplicate_prefix = true,
      separator_style = "thick",
      hover = { enabled = true, delay = 200, reveal = { "close" } },
      sort_by = "insert_at_end",
      groups = {
        options = { toggle_hidden_on_enter = true },
        items = {
          {
            name = "Tests",
            highlight = { underline = true, sp = "#89b4fa" },
            priority = 2,
            icon = "",
            matcher = function(buf)
              return buf.name:match("%_test") or buf.name:match("%_spec")
            end,
          },
        },
      },
    },
  },
  keys = {
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
  },
}

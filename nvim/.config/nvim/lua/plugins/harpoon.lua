return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED: Setup harpoon
    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
          -- Per-project harpoon lists based on git root or cwd
          return vim.uv.cwd()
        end,
      },
    })
  end,
  keys = {
    {
      "<leader>ha",
      function()
        require("harpoon"):list():add()
        vim.notify("File added to Harpoon", vim.log.levels.INFO)
      end,
      desc = "Harpoon: Add file",
    },
    {
      "<leader>hm",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon: Toggle menu",
    },
    {
      "<leader>h1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon: Go to file 1",
    },
    {
      "<leader>h2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon: Go to file 2",
    },
    {
      "<leader>h3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon: Go to file 3",
    },
    {
      "<leader>h4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon: Go to file 4",
    },
    {
      "<leader>h5",
      function()
        require("harpoon"):list():select(5)
      end,
      desc = "Harpoon: Go to file 5",
    },
    {
      "<leader>hn",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Harpoon: Next file",
    },
    {
      "<leader>hp",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Harpoon: Previous file",
    },
    {
      "<leader>hr",
      function()
        require("harpoon"):list():remove()
        vim.notify("File removed from Harpoon", vim.log.levels.INFO)
      end,
      desc = "Harpoon: Remove file",
    },
    {
      "<leader>hc",
      function()
        require("harpoon"):list():clear()
        vim.notify("Harpoon list cleared", vim.log.levels.INFO)
      end,
      desc = "Harpoon: Clear list",
    },
  },
}

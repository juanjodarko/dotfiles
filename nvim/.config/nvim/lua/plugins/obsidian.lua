return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function() 
    require("obsidian").setup({
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/obsidian-notes",
        },
        --{
        --  name = "workshop",
        --  path = "~/Documents/notes",
        --},
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      mappings = {
        ["<leader>of"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true }
        },
        ["<leader>od"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true }
        },
      },
      new_notes_location = "current_dir",
      note_frontmatter_func = function(note)
        local out = { id = note.id, aliases = note.aliases, tags = note.tags, area = "", project = "" }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
      templates = {
        subdir = "Templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
        tags = "",
      },
    })
  end,

  -- Keybindings for common Obsidian operations
  keys = {
    -- Daily Notes (Hybrid approach: create in Obsidian with Templater, open in Neovim)
    {
      "<leader>oo",
      function()
        -- Open today's daily note (assumes created in Obsidian with Templater)
        local date = os.date("%Y-%m-%d-%A")
        local path = "~/Documents/obsidian-notes/1.Projects/0.Dailies/" .. date .. ".md"
        local expanded = vim.fn.expand(path)

        if vim.fn.filereadable(expanded) == 1 then
          vim.cmd("edit " .. expanded)
        else
          vim.notify(
            "Daily note doesn't exist. Create it in Obsidian first with Templater.",
            vim.log.levels.WARN
          )
        end
      end,
      desc = "Obsidian: Open today's daily note"
    },

    {
      "<leader>oy",
      function()
        -- Open yesterday's daily note
        local yesterday = os.time() - (24 * 60 * 60)
        local date = os.date("%Y-%m-%d-%A", yesterday)
        local path = "~/Documents/obsidian-notes/1.Projects/0.Dailies/" .. date .. ".md"
        local expanded = vim.fn.expand(path)

        if vim.fn.filereadable(expanded) == 1 then
          vim.cmd("edit " .. expanded)
        else
          vim.notify("Yesterday's daily note doesn't exist.", vim.log.levels.WARN)
        end
      end,
      desc = "Obsidian: Open yesterday's daily note"
    },

    -- Navigation
    { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Obsidian: Search notes" },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", desc = "Obsidian: Quick switch" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Obsidian: Show backlinks" },

    -- Creation
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Obsidian: New note (current dir)" },

    -- Editing helpers (mappings <leader>of and <leader>od defined in config above)
  },
}

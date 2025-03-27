return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      --{
      --  name = "personal",
      --  path = "~/Documents/obsidian-notes",
      --},
      {
        name = "workshop",
        path = "~/Documents/notes",
      },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
      new_notes_location = "current_dir",
      prepend_note_id = true
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
  },
}

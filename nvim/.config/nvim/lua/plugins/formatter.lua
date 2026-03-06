return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<F3>",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    -- Define formatters for each language with project-aware detection
    formatters_by_ft = {
      -- Ruby & Rails
      ruby = function()
        local project_utils = require('user.project_utils')
        if project_utils.find_executable('standardrb') then
          return { "standardrb" }
        elseif project_utils.find_executable('rubocop') then
          return { "rubocop" }
        else
          return {}
        end
      end,
      
      -- JavaScript/TypeScript/React
      javascript = { "prettier", "eslint_d" },
      typescript = { "prettier", "eslint_d" },
      javascriptreact = { "prettier", "eslint_d" },
      typescriptreact = { "prettier", "eslint_d" },
      
      -- Web technologies
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      
      -- Go
      go = { "gofumpt", "goimports" },

      -- Elixir
      elixir = { "mix" },

      -- Rust
      rust = { "rustfmt" },

      -- C++
      cpp = { "clang_format" },
      c = { "clang_format" },

      -- Other languages
      lua = { "stylua" },
      python = { "isort", "black" },
      sh = { "shfmt" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      -- GraphQL
      graphql = { "prettier" },
    },
    
    -- Format on save configuration
    format_on_save = function(bufnr)
      -- Disable format on save for specific file types or projects
      local disabled_filetypes = { "sql", "java" }
      if vim.tbl_contains(disabled_filetypes, vim.bo[bufnr].filetype) then
        return
      end

      -- Only format if the file is part of a project (has version control)
      local project_utils = require('user.project_utils')
      local root = project_utils.get_project_root()
      if not root or root == vim.fn.expand('~') then
        return
      end

      return {
        timeout_ms = 2000,
        lsp_fallback = true,
        quiet = false,
      }
    end,
    
    -- Configure individual formatters
    formatters = {
      standardrb = {
        command = function()
          local project_utils = require('user.project_utils')
          return project_utils.find_executable('standardrb') or 'standardrb'
        end,
      },
      rubocop = {
        command = function()
          local project_utils = require('user.project_utils')
          return project_utils.find_executable('rubocop') or 'rubocop'
        end,
        args = { '--auto-correct', '--format', 'quiet', '--stderr', '-' },
      },
      mix = {
        command = "mix",
        args = { "format", "-" },
        stdin = true,
      },
    },
  },
  init = function()
    -- Use conform for gq formatting
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
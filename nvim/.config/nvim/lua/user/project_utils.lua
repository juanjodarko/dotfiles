-- Project detection utilities for intelligent LSP configuration
local M = {}

-- Get the root directory of the current project
function M.get_project_root()
  local cwd = vim.fn.getcwd()
  local markers = {
    -- Git
    '.git',
    -- Ruby/Rails
    'Gemfile', 'config.ru', 'app/controllers', 'bin/rails',
    -- JavaScript/TypeScript/Node.js
    'package.json', 'tsconfig.json', 'jsconfig.json', 'yarn.lock', 'pnpm-lock.yaml',
    -- React specific
    'src/App.tsx', 'src/App.jsx', 'public/index.html',
    -- Go
    'go.mod', 'go.sum', 'main.go',
    -- Elixir
    'mix.exs', 'config/config.exs', 'lib/',
    -- C++
    'CMakeLists.txt', 'Makefile', 'configure.ac', 'meson.build',
    -- General
    '.nvim.lua', '.nvimrc'
  }
  
  return vim.fs.dirname(vim.fs.find(markers, { upward = true })[1]) or cwd
end

-- Detect project type based on files and structure
function M.detect_project_type()
  local root = M.get_project_root()
  local project_types = {}
  
  -- Check for specific project files
  local checks = {
    ruby = {
      'Gemfile', 'Rakefile', '*.gemspec', '.ruby-version'
    },
    rails = {
      'config.ru', 'app/controllers', 'bin/rails', 'config/application.rb'
    },
    javascript = {
      'package.json'
    },
    react = {
      'src/App.tsx', 'src/App.jsx', 'public/index.html',
      -- Check package.json for React dependencies
      function()
        local package_json = root .. '/package.json'
        if vim.fn.filereadable(package_json) == 1 then
          local content = vim.fn.readfile(package_json)
          local json_str = table.concat(content, '\n')
          return string.find(json_str, '"react"') ~= nil
        end
        return false
      end
    },
    typescript = {
      'tsconfig.json', '*.ts', '*.tsx'
    },
    nodejs = {
      'package.json', 'server.js', 'index.js', 'app.js'
    },
    go = {
      'go.mod', 'go.sum', 'main.go', '*.go'
    },
    elixir = {
      'mix.exs', 'config/config.exs'
    },
    cpp = {
      'CMakeLists.txt', 'Makefile', '*.cpp', '*.hpp', '*.cc', '*.cxx'
    }
  }
  
  for project_type, patterns in pairs(checks) do
    for _, pattern in ipairs(patterns) do
      if type(pattern) == 'function' then
        if pattern() then
          table.insert(project_types, project_type)
          break
        end
      else
        local files = vim.fn.glob(root .. '/' .. pattern, true, true)
        if #files > 0 then
          table.insert(project_types, project_type)
          break
        end
      end
    end
  end
  
  return project_types
end

-- Check if specific tools are available
function M.find_executable(names)
  if type(names) == 'string' then
    names = { names }
  end
  
  for _, name in ipairs(names) do
    -- Check rbenv/asdf paths first, then system PATH
    local paths = {
      vim.fn.expand("~/.rbenv/shims/" .. name),
      vim.fn.expand("~/.asdf/shims/" .. name),
      name  -- system PATH
    }
    
    for _, path in ipairs(paths) do
      if vim.fn.executable(path) == 1 then
        return path
      end
    end
  end
  
  return nil
end

-- Load project-specific configuration overrides
function M.load_project_config_file()
  local root = M.get_project_root()
  local config_files = {
    root .. '/.nvim.lua',
    root .. '/.nvimrc.lua', 
    root .. '/.config/nvim.lua'
  }
  
  for _, config_file in ipairs(config_files) do
    if vim.fn.filereadable(config_file) == 1 then
      local ok, project_config = pcall(dofile, config_file)
      if ok and type(project_config) == 'table' then
        return project_config
      end
    end
  end
  
  return {}
end

-- Get project-specific configuration
function M.get_project_config()
  local project_types = M.detect_project_type()
  local root = M.get_project_root()
  local project_overrides = M.load_project_config_file()
  
  local config = {
    root_dir = root,
    project_types = project_types,
    is_ruby = vim.tbl_contains(project_types, 'ruby'),
    is_rails = vim.tbl_contains(project_types, 'rails'),
    is_javascript = vim.tbl_contains(project_types, 'javascript'),
    is_react = vim.tbl_contains(project_types, 'react'),
    is_typescript = vim.tbl_contains(project_types, 'typescript'),
    is_nodejs = vim.tbl_contains(project_types, 'nodejs'),
    is_go = vim.tbl_contains(project_types, 'go'),
    is_elixir = vim.tbl_contains(project_types, 'elixir'),
    is_cpp = vim.tbl_contains(project_types, 'cpp'),
  }
  
  -- Merge project-specific overrides (project config takes priority)
  config = vim.tbl_deep_extend('force', config, project_overrides)
  
  return config
end

-- Get project-specific LSP server overrides
function M.get_lsp_overrides(server_name)
  local project_config = M.get_project_config()
  
  if project_config.lsp and project_config.lsp[server_name] then
    return project_config.lsp[server_name]
  end
  
  return {}
end

-- Check if LSP server should be disabled for this project
function M.is_lsp_disabled(server_name)
  local project_config = M.get_project_config()
  
  if project_config.lsp and project_config.lsp.disable then
    return vim.tbl_contains(project_config.lsp.disable, server_name)
  end
  
  return false
end

return M
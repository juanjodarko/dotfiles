-- Project detection utilities for intelligent LSP configuration
local M = {}

-- Get the root directory of the current project
function M.get_project_root()
  local cwd = vim.fn.getcwd()
  local markers = {
    -- Monorepo markers (HIGHEST PRIORITY - check first!)
    'pnpm-workspace.yaml',
    'lerna.json',
    'nx.json',
    -- Git
    '.git',
    -- Ruby/Rails
    'Gemfile', 'config.ru', 'app/controllers', 'bin/rails',
    -- JavaScript/TypeScript/Node.js
    'package.json', 'tsconfig.json', 'jsconfig.json', 'yarn.lock', 'pnpm-lock.yaml',
    -- React specific
    'src/App.tsx', 'src/App.jsx', 'public/index.html',
    -- GraphQL
    '.graphqlrc', 'graphql.config.js', 'schema.graphql',
    -- Python
    'pyproject.toml', 'setup.py', 'requirements.txt', 'Pipfile',
    -- Rust
    'Cargo.toml', 'rust-project.json',
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

-- Get monorepo root (prioritizes monorepo markers over package.json)
function M.get_monorepo_root()
  local cwd = vim.fn.getcwd()
  local monorepo_markers = {
    'pnpm-workspace.yaml',
    'lerna.json',
    'nx.json',
    'turbo.json',
  }

  -- Check for monorepo markers first
  local monorepo_root = vim.fs.dirname(vim.fs.find(monorepo_markers, { upward = true })[1])
  if monorepo_root then
    return monorepo_root
  end

  -- Fall back to regular project root
  return M.get_project_root()
end

-- Detect if current project is a monorepo
function M.is_monorepo()
  local root = M.get_project_root()
  local monorepo_files = {
    root .. '/pnpm-workspace.yaml',
    root .. '/lerna.json',
    root .. '/nx.json',
    root .. '/turbo.json',
  }

  for _, file in ipairs(monorepo_files) do
    if vim.fn.filereadable(file) == 1 then
      return true
    end
  end

  return false
end

-- Get list of workspace packages in a monorepo
function M.get_workspace_packages()
  if not M.is_monorepo() then
    return {}
  end

  local root = M.get_monorepo_root()
  local packages = {}

  -- Try to read pnpm-workspace.yaml
  local workspace_file = root .. '/pnpm-workspace.yaml'
  if vim.fn.filereadable(workspace_file) == 1 then
    local content = vim.fn.readfile(workspace_file)
    -- Simple parsing - look for packages: section
    local in_packages = false
    for _, line in ipairs(content) do
      if line:match('^packages:') then
        in_packages = true
      elseif in_packages and line:match('^%s+-%s*(.+)') then
        local pattern = line:match('^%s+-%s*(.+)')
        pattern = pattern:gsub('"', ''):gsub("'", '')
        -- Expand glob patterns
        local dirs = vim.fn.glob(root .. '/' .. pattern, true, true)
        for _, dir in ipairs(dirs) do
          if vim.fn.isdirectory(dir) == 1 then
            table.insert(packages, vim.fn.fnamemodify(dir, ':t'))
          end
        end
      elseif in_packages and not line:match('^%s') then
        break
      end
    end
  end

  return packages
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
    graphql = {
      '.graphqlrc', '.graphqlrc.yml', '.graphqlrc.yaml', '.graphqlrc.json',
      'graphql.config.js', 'graphql.config.ts', '*.graphql', '*.gql',
      'schema.graphql'
    },
    python = {
      'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt',
      'Pipfile', 'pytest.ini', 'tox.ini', '*.py'
    },
    rust = {
      'Cargo.toml', 'Cargo.lock', 'rust-project.json', '*.rs'
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
    is_monorepo = M.is_monorepo(),
    monorepo_root = M.get_monorepo_root(),
    workspace_packages = M.get_workspace_packages(),
    is_ruby = vim.tbl_contains(project_types, 'ruby'),
    is_rails = vim.tbl_contains(project_types, 'rails'),
    is_javascript = vim.tbl_contains(project_types, 'javascript'),
    is_react = vim.tbl_contains(project_types, 'react'),
    is_typescript = vim.tbl_contains(project_types, 'typescript'),
    is_nodejs = vim.tbl_contains(project_types, 'nodejs'),
    is_graphql = vim.tbl_contains(project_types, 'graphql'),
    is_python = vim.tbl_contains(project_types, 'python'),
    is_rust = vim.tbl_contains(project_types, 'rust'),
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

-- ==========================================
-- DOCKER COMPOSE DETECTION (for testing)
-- ==========================================

-- Detect Docker Compose files in project
function M.has_docker_compose()
  local root = M.get_project_root()
  local docker_files = {
    'docker-compose.yml',
    'compose.yml',
    'docker-compose.yaml',
    'compose.yaml',
  }

  for _, file in ipairs(docker_files) do
    local full_path = root .. '/' .. file
    if vim.fn.filereadable(full_path) == 1 then
      return true, full_path
    end
  end

  return false, nil
end

-- Detect Docker service name from compose file
function M.detect_docker_service(service_hint)
  local has_docker, compose_file = M.has_docker_compose()
  if not has_docker then
    return nil
  end

  -- Common service names to check (in priority order)
  local common_names = {
    service_hint or "app",  -- Use hint first if provided
    "app",
    "web",
    "backend",
    "api",
    "server",
    "frontend",
  }

  -- Read compose file and check for service names
  local ok, content = pcall(vim.fn.readfile, compose_file)
  if not ok then
    return common_names[1]  -- Fallback to first common name
  end

  -- Simple YAML parsing - look for "servicename:" at start of line
  for _, name in ipairs(common_names) do
    for _, line in ipairs(content) do
      -- Match service definition: "  servicename:" or "servicename:"
      if line:match("^%s*" .. name .. "%s*:") then
        return name
      end
    end
  end

  -- If no match found, return the hint or first common name
  return service_hint or common_names[1]
end

-- Build Docker Compose test command
function M.build_docker_test_command(base_cmd, service_name)
  local has_docker = M.has_docker_compose()
  if not has_docker then
    -- No Docker Compose file, return base command
    return base_cmd
  end

  -- Detect or use provided service name
  local service = service_name or M.detect_docker_service()
  if not service then
    return base_cmd
  end

  -- Build Docker Compose command
  return vim.iter({
    "docker",
    "compose",
    "run",
    "--rm",
    service,
    base_cmd,
  }):flatten():totable()
end

-- ==========================================
-- DOCKER COMPOSE DETECTION (for debugging)
-- ==========================================

-- Get standard debug port for a language
function M.get_debug_port_for_language(language)
  local debug_ports = {
    ruby = 38698,      -- rdbg (Ruby Debug)
    javascript = 9229, -- Node.js Inspector
    typescript = 9229, -- Node.js Inspector
    go = 2345,         -- Delve
    python = 5678,     -- debugpy
  }

  return debug_ports[language] or nil
end

-- Detect container working directory from compose file or Dockerfile
function M.detect_container_workdir(service_name)
  local has_docker, compose_file = M.has_docker_compose()
  if not has_docker then
    return "/app"  -- Default fallback
  end

  -- Read compose file and look for working_dir directive
  local ok, content = pcall(vim.fn.readfile, compose_file)
  if not ok then
    return "/app"
  end

  -- Simple YAML parsing - look for working_dir under service
  local in_service = false
  local service_indent = nil

  for _, line in ipairs(content) do
    -- Check if we found the service
    if line:match("^%s*" .. (service_name or "app") .. "%s*:") then
      in_service = true
      service_indent = #line:match("^%s*")
    elseif in_service then
      local current_indent = #line:match("^%s*")

      -- Still within service block
      if current_indent > service_indent then
        -- Look for working_dir
        local workdir = line:match("working_dir:%s*(.+)")
        if workdir then
          return workdir:gsub('"', ''):gsub("'", ''):gsub("%s+$", "")
        end
      else
        -- Exited service block
        break
      end
    end
  end

  -- If no working_dir found, try to read Dockerfile
  local root = M.get_project_root()
  local dockerfile = root .. '/Dockerfile'
  if vim.fn.filereadable(dockerfile) == 1 then
    local dockerfile_content = vim.fn.readfile(dockerfile)
    for _, line in ipairs(dockerfile_content) do
      local workdir = line:match("^WORKDIR%s+(.+)")
      if workdir then
        return workdir:gsub("%s+$", "")
      end
    end
  end

  -- Default fallback
  return "/app"
end

-- Build Docker DAP configuration for a language
-- Returns a DAP configuration table ready to be inserted into dap.configurations
function M.build_docker_dap_config(language, service_name)
  local has_docker = M.has_docker_compose()
  if not has_docker then
    return nil
  end

  local service = service_name or M.detect_docker_service()
  if not service then
    return nil
  end

  local port = M.get_debug_port_for_language(language)
  if not port then
    return nil
  end

  local workdir = M.detect_container_workdir(service)
  local local_root = vim.fn.getcwd()

  -- Language-specific configuration
  local configs = {
    ruby = {
      type = "ruby",
      name = "Debug in Docker (attach)",
      request = "attach",
      localfs = false,
      host = "127.0.0.1",
      port = port,
      pathMappings = {
        {
          localRoot = local_root,
          remoteRoot = workdir,
        }
      },
    },

    javascript = {
      type = "pwa-node",
      name = "Debug in Docker (attach)",
      request = "attach",
      address = "localhost",
      port = port,
      localRoot = local_root,
      remoteRoot = workdir,
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
    },

    typescript = {
      type = "pwa-node",
      name = "Debug in Docker (attach)",
      request = "attach",
      address = "localhost",
      port = port,
      localRoot = local_root,
      remoteRoot = workdir,
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
    },

    go = {
      type = "delve",
      name = "Debug in Docker (attach)",
      mode = "remote",
      request = "attach",
      host = "127.0.0.1",
      port = port,
      substitutePath = {
        {
          from = local_root,
          to = workdir,
        }
      },
    },

    python = {
      type = "python",
      name = "Debug in Docker (attach)",
      request = "attach",
      connect = {
        host = "localhost",
        port = port,
      },
      pathMappings = {
        {
          localRoot = local_root,
          remoteRoot = workdir,
        }
      },
    },
  }

  return configs[language]
end

return M
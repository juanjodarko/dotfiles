-- Git utilities with monorepo awareness
local M = {}

local project_utils = require('user.project_utils')

-- ==========================================
-- MONOREPO DETECTION
-- ==========================================

-- Get current package directory in monorepo
function M.get_current_package()
  if not project_utils.is_monorepo() then
    return nil
  end

  local current_file = vim.fn.expand('%:p')
  local monorepo_root = project_utils.get_monorepo_root()

  if not current_file:find(monorepo_root, 1, true) then
    return nil
  end

  -- Find the closest package.json up the tree
  local current_dir = vim.fn.expand('%:p:h')
  while current_dir ~= monorepo_root and current_dir ~= '/' do
    local package_json = current_dir .. '/package.json'
    if vim.fn.filereadable(package_json) == 1 then
      -- This is a package directory
      return {
        path = current_dir,
        name = vim.fn.fnamemodify(current_dir, ':t'),
        relative_path = current_dir:gsub(monorepo_root .. '/', '')
      }
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end

  return nil
end

-- Get all packages in monorepo
function M.get_all_packages()
  if not project_utils.is_monorepo() then
    return {}
  end

  local packages = {}
  local monorepo_root = project_utils.get_monorepo_root()

  -- Common monorepo patterns
  local patterns = {
    'packages/*/package.json',
    'apps/*/package.json',
    'libs/*/package.json',
    'services/*/package.json',
  }

  for _, pattern in ipairs(patterns) do
    local files = vim.fn.glob(monorepo_root .. '/' .. pattern, true, true)
    for _, file in ipairs(files) do
      local pkg_dir = vim.fn.fnamemodify(file, ':h')
      table.insert(packages, {
        path = pkg_dir,
        name = vim.fn.fnamemodify(pkg_dir, ':t'),
        relative_path = pkg_dir:gsub(monorepo_root .. '/', '')
      })
    end
  end

  return packages
end

-- ==========================================
-- GIT OPERATIONS
-- ==========================================

-- Execute git command and return output
local function git_exec(cmd, opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()

  local full_cmd = 'git -C ' .. vim.fn.shellescape(cwd) .. ' ' .. cmd
  local output = vim.fn.system(full_cmd)
  local success = vim.v.shell_error == 0

  return {
    success = success,
    output = output,
    exit_code = vim.v.shell_error
  }
end

-- Check if we have uncommitted changes
function M.has_uncommitted_changes()
  local result = git_exec('status --porcelain')
  return result.success and result.output ~= ''
end

-- Check if we're behind remote
function M.is_behind_remote()
  -- Fetch first
  git_exec('fetch --quiet')

  local result = git_exec('rev-list HEAD..@{upstream} --count')
  if not result.success then
    return false, "No upstream branch configured"
  end

  local count = tonumber(result.output:gsub('%s+', ''))
  return count and count > 0, count
end

-- Check if we're ahead of remote
function M.is_ahead_of_remote()
  local result = git_exec('rev-list @{upstream}..HEAD --count')
  if not result.success then
    return false, "No upstream branch configured"
  end

  local count = tonumber(result.output:gsub('%s+', ''))
  return count and count > 0, count
end

-- Get current branch name
function M.get_current_branch()
  local result = git_exec('branch --show-current')
  if result.success then
    return result.output:gsub('%s+', '')
  end
  return nil
end

-- Check if branch is a feature branch (not main/master/develop)
function M.is_feature_branch()
  local branch = M.get_current_branch()
  if not branch then
    return false
  end

  local protected_branches = { 'main', 'master', 'develop', 'development', 'staging', 'production' }
  for _, protected in ipairs(protected_branches) do
    if branch == protected then
      return false
    end
  end

  return true
end

-- ==========================================
-- SMART GIT OPERATIONS
-- ==========================================

-- Smart pull with rebase
function M.smart_pull()
  -- Check for uncommitted changes
  if M.has_uncommitted_changes() then
    vim.notify("You have uncommitted changes. Please commit or stash them first.", vim.log.levels.WARN)
    return false
  end

  local branch = M.get_current_branch()
  if not branch then
    vim.notify("Not on a branch", vim.log.levels.ERROR)
    return false
  end

  -- Determine strategy based on branch type
  local should_rebase = M.is_feature_branch()
  local strategy = should_rebase and '--rebase' or ''

  vim.notify(string.format("Pulling %s with %s...", branch, should_rebase and "rebase" or "merge"), vim.log.levels.INFO)

  local result = git_exec('pull ' .. strategy)

  if result.success then
    vim.notify("Pull successful!", vim.log.levels.INFO)
    return true
  else
    vim.notify("Pull failed:\n" .. result.output, vim.log.levels.ERROR)
    return false
  end
end

-- Smart push with safety checks
function M.smart_push(force)
  local branch = M.get_current_branch()
  if not branch then
    vim.notify("Not on a branch", vim.log.levels.ERROR)
    return false
  end

  -- Check if we need to pull first
  local behind, count = M.is_behind_remote()
  if behind then
    vim.notify(string.format("You are %d commits behind. Pull first!", count), vim.log.levels.WARN)
    return false
  end

  local push_cmd = force and 'push --force-with-lease' or 'push'

  -- Check if upstream is set
  local has_upstream = git_exec('rev-parse --abbrev-ref @{upstream}').success
  if not has_upstream then
    push_cmd = push_cmd .. ' -u origin ' .. branch
    vim.notify(string.format("Setting upstream to origin/%s", branch), vim.log.levels.INFO)
  end

  vim.notify("Pushing...", vim.log.levels.INFO)

  local result = git_exec(push_cmd)

  if result.success then
    vim.notify("Push successful!", vim.log.levels.INFO)
    return true
  else
    vim.notify("Push failed:\n" .. result.output, vim.log.levels.ERROR)
    return false
  end
end

-- ==========================================
-- MONOREPO GIT OPERATIONS
-- ==========================================

-- Get git log for current package
function M.monorepo_log()
  local pkg = M.get_current_package()
  if not pkg then
    vim.notify("Not in a monorepo package", vim.log.levels.WARN)
    return
  end

  local monorepo_root = project_utils.get_monorepo_root()
  vim.cmd(string.format('Git log -- %s', pkg.relative_path))
end

-- Get git diff for current package
function M.monorepo_diff(commit)
  local pkg = M.get_current_package()
  if not pkg then
    vim.notify("Not in a monorepo package", vim.log.levels.WARN)
    return
  end

  local monorepo_root = project_utils.get_monorepo_root()
  local diff_cmd = commit and string.format('Git diff %s -- %s', commit, pkg.relative_path)
                          or string.format('Git diff -- %s', pkg.relative_path)
  vim.cmd(diff_cmd)
end

-- Get changed files in current package
function M.monorepo_changed_files()
  local pkg = M.get_current_package()
  if not pkg then
    vim.notify("Not in a monorepo package", vim.log.levels.WARN)
    return {}
  end

  local monorepo_root = project_utils.get_monorepo_root()
  local result = git_exec(string.format('diff --name-only -- %s', pkg.relative_path), { cwd = monorepo_root })

  if result.success then
    local files = {}
    for file in result.output:gmatch('[^\r\n]+') do
      table.insert(files, file)
    end
    return files
  end

  return {}
end

-- Show package info with git stats
function M.show_package_info()
  local pkg = M.get_current_package()
  if not pkg then
    vim.notify("Not in a monorepo package", vim.log.levels.WARN)
    return
  end

  local monorepo_root = project_utils.get_monorepo_root()

  -- Get commit count for package
  local commit_result = git_exec(string.format('rev-list --count HEAD -- %s', pkg.relative_path), { cwd = monorepo_root })
  local commit_count = commit_result.success and commit_result.output:gsub('%s+', '') or '?'

  -- Get changed files count
  local changed_files = M.monorepo_changed_files()
  local changed_count = #changed_files

  -- Get last commit for package
  local last_commit_result = git_exec(string.format('log -1 --format="%%h - %%s (%%ar)" -- %s', pkg.relative_path), { cwd = monorepo_root })
  local last_commit = last_commit_result.success and last_commit_result.output:gsub('%s+$', '') or 'No commits'

  local info = string.format([[
Package: %s
Path: %s
Total commits: %s
Changed files: %d
Last commit: %s
]], pkg.name, pkg.relative_path, commit_count, changed_count, last_commit)

  vim.notify(info, vim.log.levels.INFO)
end

-- ==========================================
-- VIM COMMANDS
-- ==========================================

-- Register commands
function M.setup_commands()
  -- Monorepo commands
  vim.api.nvim_create_user_command('GitMonoLog', M.monorepo_log, { desc = 'Git log for current package' })
  vim.api.nvim_create_user_command('GitMonoDiff', function(opts)
    M.monorepo_diff(opts.args ~= '' and opts.args or nil)
  end, { nargs = '?', desc = 'Git diff for current package' })
  vim.api.nvim_create_user_command('GitMonoFiles', function()
    local files = M.monorepo_changed_files()
    if #files == 0 then
      vim.notify("No changed files in current package", vim.log.levels.INFO)
    else
      vim.notify("Changed files:\n" .. table.concat(files, '\n'), vim.log.levels.INFO)
    end
  end, { desc = 'Show changed files in current package' })
  vim.api.nvim_create_user_command('GitMonoInfo', M.show_package_info, { desc = 'Show package git info' })

  -- Smart git operations
  vim.api.nvim_create_user_command('GitSmartPull', M.smart_pull, { desc = 'Smart pull with rebase for feature branches' })
  vim.api.nvim_create_user_command('GitSmartPush', function(opts)
    M.smart_push(opts.bang)
  end, { bang = true, desc = 'Smart push with safety checks (use ! for force)' })
end

return M

return {
  "tpope/vim-fugitive",
  dependencies = {
    "tpope/vim-rhubarb"
  },
  config = function()
    -- Setup git utilities and commands
    local git_utils = require('user.git_utils')
    git_utils.setup_commands()

    -- Standard keymap helper
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
    end

    -- Basic Fugitive commands
    map('n', '<leader>Gs', ':Git<cr>', "Git: Status")
    map('n', '<leader>Gc', ':Git commit<cr>', "Git: Commit")
    map('n', '<leader>Gd', ':Gdiffsplit<cr>', "Git: Diff split")
    map('n', '<leader>Gb', ':Git blame<cr>', "Git: Blame")
    map('n', '<leader>Gl', ':Git log<cr>', "Git: Log")

    -- Smart pull/push operations
    map('n', '<leader>Gp', function()
      git_utils.smart_pull()
    end, "Git: Smart pull (rebase on feature branches)")

    map('n', '<leader>GP', function()
      git_utils.smart_push()
    end, "Git: Smart push (with safety checks)")

    map('n', '<leader>GF', ':Git push --force-with-lease<cr>', "Git: Force push (with lease)")

    -- Fetch operations
    map('n', '<leader>Gf', ':Git fetch --all<cr>', "Git: Fetch all")

    -- Branch operations
    map('n', '<leader>Gb', ':Git branch<cr>', "Git: Branch list")
    map('n', '<leader>Gco', ':Git checkout ', "Git: Checkout")
    map('n', '<leader>Gcb', ':Git checkout -b ', "Git: Create branch")

    -- Merge/Rebase operations with monorepo awareness
    map('n', '<leader>Gm', function()
      local branch = git_utils.get_current_branch()
      if branch then
        vim.ui.input({ prompt = 'Merge branch: ', default = 'main' }, function(input)
          if input and input ~= '' then
            vim.cmd('Git merge ' .. input)
          end
        end)
      end
    end, "Git: Merge (monorepo-aware)")

    map('n', '<leader>Gr', function()
      local branch = git_utils.get_current_branch()
      if branch then
        vim.ui.input({ prompt = 'Rebase onto: ', default = 'main' }, function(input)
          if input and input ~= '' then
            vim.cmd('Git rebase ' .. input)
          end
        end)
      end
    end, "Git: Rebase (monorepo-aware)")

    -- Stash operations
    map('n', '<leader>Gss', ':Git stash<cr>', "Git: Stash")
    map('n', '<leader>Gsp', ':Git stash pop<cr>', "Git: Stash pop")
    map('n', '<leader>Gsl', ':Git stash list<cr>', "Git: Stash list")

    -- Monorepo-specific operations
    map('n', '<leader>gMl', function()
      git_utils.monorepo_log()
    end, "Git: Monorepo log (current package)")

    map('n', '<leader>gMd', function()
      git_utils.monorepo_diff()
    end, "Git: Monorepo diff (current package)")

    map('n', '<leader>gMf', function()
      local files = git_utils.monorepo_changed_files()
      if #files == 0 then
        vim.notify("No changed files in current package", vim.log.levels.INFO)
      else
        vim.notify("Changed files:\n" .. table.concat(files, '\n'), vim.log.levels.INFO)
      end
    end, "Git: Monorepo changed files")

    map('n', '<leader>gMc', function()
      local pkg = git_utils.get_current_package()
      if pkg then
        vim.cmd(string.format('Git log --oneline -- %s', pkg.relative_path))
      else
        vim.notify("Not in a monorepo package", vim.log.levels.WARN)
      end
    end, "Git: Monorepo commits (current package)")

    map('n', '<leader>gMp', function()
      git_utils.show_package_info()
    end, "Git: Monorepo package info")
  end,
}

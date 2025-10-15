-- Monorepo utility commands for pnpm workspaces
local project_utils = require('user.project_utils')

local M = {}

-- Show monorepo information
function M.show_info()
    local config = project_utils.get_project_config()

    if not config.is_monorepo then
        vim.notify("Not a monorepo project", vim.log.levels.INFO)
        return
    end

    local lines = {
        "📦 Monorepo Information",
        "",
        "Root: " .. config.monorepo_root,
        "Type: pnpm workspace",
        "",
        "Workspace Packages (" .. #config.workspace_packages .. "):",
    }

    for _, pkg in ipairs(config.workspace_packages) do
        table.insert(lines, "  • " .. pkg)
    end

    table.insert(lines, "")
    table.insert(lines, "LSP Configuration:")
    table.insert(lines, "  TypeScript root: " .. (config.monorepo_root or "N/A"))
    table.insert(lines, "  ESLint root: " .. (config.monorepo_root or "N/A"))

    -- Create a floating window to display info
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

    local width = 60
    local height = #lines
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = 'minimal',
        border = 'rounded',
        title = ' Monorepo Info ',
        title_pos = 'center',
    })

    -- Close on q or Esc
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- List all workspace packages
function M.list_packages()
    local config = project_utils.get_project_config()

    if not config.is_monorepo then
        vim.notify("Not a monorepo project", vim.log.levels.INFO)
        return
    end

    if #config.workspace_packages == 0 then
        vim.notify("No workspace packages found", vim.log.levels.WARN)
        return
    end

    vim.ui.select(config.workspace_packages, {
        prompt = "Select package to navigate:",
        format_item = function(item)
            return "📦 " .. item
        end,
    }, function(choice)
        if choice then
            local pkg_path = config.monorepo_root .. "/packages/" .. choice
            if vim.fn.isdirectory(pkg_path) == 1 then
                vim.cmd("cd " .. pkg_path)
                vim.notify("Changed directory to: " .. choice, vim.log.levels.INFO)
            else
                -- Try apps/ directory
                pkg_path = config.monorepo_root .. "/apps/" .. choice
                if vim.fn.isdirectory(pkg_path) == 1 then
                    vim.cmd("cd " .. pkg_path)
                    vim.notify("Changed directory to: " .. choice, vim.log.levels.INFO)
                else
                    vim.notify("Package directory not found: " .. choice, vim.log.levels.ERROR)
                end
            end
        end
    end)
end

-- Show current LSP workspace info
function M.show_lsp_workspace()
    local clients = vim.lsp.get_clients()

    if #clients == 0 then
        vim.notify("No LSP clients attached", vim.log.levels.INFO)
        return
    end

    local lines = {"🔧 LSP Workspace Information", ""}

    for _, client in ipairs(clients) do
        table.insert(lines, "Server: " .. client.name)
        table.insert(lines, "  Root: " .. (client.config.root_dir or "N/A"))

        if client.config.workspace_folders then
            table.insert(lines, "  Workspace folders:")
            for _, folder in ipairs(client.config.workspace_folders) do
                table.insert(lines, "    • " .. folder.name)
            end
        end
        table.insert(lines, "")
    end

    -- Create a floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    local width = 70
    local height = math.min(#lines, 20)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = 'minimal',
        border = 'rounded',
        title = ' LSP Workspace ',
        title_pos = 'center',
    })

    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- ==========================================
-- PACKAGE SCRIPT RUNNER
-- ==========================================

-- Parse package.json to extract scripts
function M.parse_package_scripts(package_json_path)
    if vim.fn.filereadable(package_json_path) ~= 1 then
        return {}
    end

    local ok, content = pcall(vim.fn.readfile, package_json_path)
    if not ok then
        return {}
    end

    local json_str = table.concat(content, '\n')

    -- Simple JSON parsing for scripts section
    local scripts = {}
    local in_scripts = false

    for _, line in ipairs(content) do
        if line:match('"scripts"%s*:%s*{') then
            in_scripts = true
        elseif in_scripts and line:match('^%s*}') then
            break
        elseif in_scripts then
            -- Match: "script-name": "command"
            local name, cmd = line:match('"([^"]+)"%s*:%s*"([^"]+)"')
            if name and cmd then
                scripts[name] = cmd
            end
        end
    end

    return scripts
end

-- Detect current workspace package
function M.detect_current_workspace()
    local config = project_utils.get_project_config()

    if not config.is_monorepo then
        return nil
    end

    local cwd = vim.fn.getcwd()
    local monorepo_root = config.monorepo_root

    -- Check if we're in a workspace package
    if cwd == monorepo_root then
        return nil  -- At root
    end

    -- Try to find package.json in current directory
    local package_json = cwd .. '/package.json'
    if vim.fn.filereadable(package_json) == 1 then
        -- Parse package name from package.json
        local content = vim.fn.readfile(package_json)
        for _, line in ipairs(content) do
            local name = line:match('"name"%s*:%s*"([^"]+)"')
            if name then
                return {
                    name = name,
                    path = cwd,
                    package_json = package_json
                }
            end
        end
    end

    return nil
end

-- Build pnpm command with workspace filter
function M.build_workspace_command(script_name)
    local config = project_utils.get_project_config()
    local workspace = M.detect_current_workspace()

    if config.is_monorepo and workspace then
        -- In a workspace package
        return string.format("pnpm --filter %s run %s", workspace.name, script_name)
    elseif config.is_monorepo then
        -- At monorepo root
        return string.format("pnpm run %s", script_name)
    else
        -- Regular project
        return string.format("pnpm run %s", script_name)
    end
end

-- Store last run command
M.last_command = nil

-- Run a package script
function M.run_script(script_name, opts)
    opts = opts or {}

    local cmd = M.build_workspace_command(script_name)

    -- Append additional arguments if provided
    if opts.args then
        cmd = cmd .. " " .. opts.args
    end

    M.last_command = cmd

    -- Use Snacks terminal for interactive output
    if Snacks and Snacks.terminal then
        Snacks.terminal(cmd, {
            cwd = vim.fn.getcwd(),
            env = vim.tbl_extend("force", vim.fn.environ(), opts.env or {}),
        })
    else
        -- Fallback to vim terminal
        vim.cmd('term ' .. cmd)
    end

    vim.notify(string.format("Running: %s", cmd), vim.log.levels.INFO)
end

-- Re-run last command
function M.run_last()
    if M.last_command then
        if Snacks and Snacks.terminal then
            Snacks.terminal(M.last_command, {
                cwd = vim.fn.getcwd(),
            })
        else
            vim.cmd('term ' .. M.last_command)
        end
        vim.notify(string.format("Re-running: %s", M.last_command), vim.log.levels.INFO)
    else
        vim.notify("No previous command to run", vim.log.levels.WARN)
    end
end

-- Update test snapshots
function M.update_snapshots()
    local workspace = M.detect_current_workspace()
    local config = project_utils.get_project_config()

    local package_json = workspace and workspace.package_json or (config.monorepo_root or vim.fn.getcwd()) .. '/package.json'

    if vim.fn.filereadable(package_json) ~= 1 then
        vim.notify("No package.json found", vim.log.levels.WARN)
        return
    end

    local scripts = M.parse_package_scripts(package_json)

    -- Detect which test script to use (prefer test:coverage:branch if available)
    local test_script = nil
    if scripts["test:coverage:branch"] then
        test_script = "test:coverage:branch"
    elseif scripts["test:unit"] then
        test_script = "test:unit"
    elseif scripts.test then
        test_script = "test"
    end

    if not test_script then
        vim.notify("No test script found in package.json", vim.log.levels.WARN)
        return
    end

    -- Run test with -u flag to update snapshots
    M.run_script(test_script, { args = "-- -u" })
end

-- Quick menu for common scripts (typecheck, lint, lint --fix, test)
function M.show_script_menu()
    -- Check if we have package.json
    local workspace = M.detect_current_workspace()
    local config = project_utils.get_project_config()

    local package_json = workspace and workspace.package_json or (config.monorepo_root or vim.fn.getcwd()) .. '/package.json'

    if vim.fn.filereadable(package_json) ~= 1 then
        vim.notify("No package.json found", vim.log.levels.WARN)
        return
    end

    local scripts = M.parse_package_scripts(package_json)

    -- Show which-key menu
    local wk = require("which-key")

    -- Build menu items in which-key spec format
    local menu_items = {
        { "<leader>m", group = "Monorepo/Package" }
    }

    if scripts.typecheck then
        table.insert(menu_items, { "<leader>mt", function() M.run_script("typecheck") end, desc = "Typecheck" })
    end

    if scripts.lint then
        table.insert(menu_items, { "<leader>ml", function() M.run_script("lint") end, desc = "Lint" })
    end

    -- Handle "lint --fix" - could be a separate script or we append --fix
    if scripts["lint:fix"] then
        table.insert(menu_items, { "<leader>mf", function() M.run_script("lint:fix") end, desc = "Lint --fix" })
    elseif scripts.lint then
        table.insert(menu_items, {
            "<leader>mf",
            function()
                local cmd = M.build_workspace_command("lint") .. " --fix"
                M.last_command = cmd
                if Snacks and Snacks.terminal then
                    Snacks.terminal(cmd, { cwd = vim.fn.getcwd() })
                else
                    vim.cmd('term ' .. cmd)
                end
                vim.notify(string.format("Running: %s", cmd), vim.log.levels.INFO)
            end,
            desc = "Lint --fix"
        })
    end

    if scripts.test then
        table.insert(menu_items, { "<leader>mx", function() M.run_script("test") end, desc = "Test" })
    end

    -- Add snapshot update option if test script exists
    if scripts.test or scripts["test:coverage:branch"] then
        table.insert(menu_items, { "<leader>mu", function() M.update_snapshots() end, desc = "Update snapshots" })
    end

    -- Add last command re-run option
    if M.last_command then
        table.insert(menu_items, { "<leader>mr", function() M.run_last() end, desc = "Re-run last" })
    end

    -- Show all scripts option
    table.insert(menu_items, { "<leader>ma", function() M.list_all_scripts() end, desc = "All scripts..." })

    -- Register and show menu
    wk.add(menu_items)

    -- Trigger the menu
    vim.defer_fn(function()
        wk.show({ keys = "<leader>m", loop = false })
    end, 10)
end

-- List all available scripts with Telescope
function M.list_all_scripts()
    local workspace = M.detect_current_workspace()
    local config = project_utils.get_project_config()

    local package_json = workspace and workspace.package_json or (config.monorepo_root or vim.fn.getcwd()) .. '/package.json'

    if vim.fn.filereadable(package_json) ~= 1 then
        vim.notify("No package.json found", vim.log.levels.WARN)
        return
    end

    local scripts = M.parse_package_scripts(package_json)

    -- Convert to list for Telescope
    local script_list = {}
    for name, cmd in pairs(scripts) do
        table.insert(script_list, {
            name = name,
            command = cmd,
            display = string.format("%-20s → %s", name, cmd)
        })
    end

    -- Sort by name
    table.sort(script_list, function(a, b) return a.name < b.name end)

    -- Use vim.ui.select for picker
    vim.ui.select(script_list, {
        prompt = "Select script to run:",
        format_item = function(item)
            return item.display
        end,
    }, function(choice)
        if choice then
            M.run_script(choice.name)
        end
    end)
end

-- Register user commands
vim.api.nvim_create_user_command('MonorepoInfo', M.show_info, { desc = "Show monorepo information" })
vim.api.nvim_create_user_command('MonorepoPackages', M.list_packages, { desc = "List and navigate to workspace packages" })
vim.api.nvim_create_user_command('MonorepoLSP', M.show_lsp_workspace, { desc = "Show LSP workspace information" })
vim.api.nvim_create_user_command('MonorepoRun', M.show_script_menu, { desc = "Quick menu for package scripts" })
vim.api.nvim_create_user_command('MonorepoRunAll', M.list_all_scripts, { desc = "List all package scripts" })
vim.api.nvim_create_user_command('MonorepoRunLast', M.run_last, { desc = "Re-run last package script" })
vim.api.nvim_create_user_command('MonorepoUpdateSnapshots', M.update_snapshots, { desc = "Update test snapshots" })

return M

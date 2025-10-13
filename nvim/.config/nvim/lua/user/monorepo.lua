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

-- Register user commands
vim.api.nvim_create_user_command('MonorepoInfo', M.show_info, { desc = "Show monorepo information" })
vim.api.nvim_create_user_command('MonorepoPackages', M.list_packages, { desc = "List and navigate to workspace packages" })
vim.api.nvim_create_user_command('MonorepoLSP', M.show_lsp_workspace, { desc = "Show LSP workspace information" })

return M

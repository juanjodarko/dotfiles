-- Theme utilities for centralized theme management
-- Reads Catppuccin flavor from central theme system

local M = {}

-- Get the current Catppuccin flavor from the centralized theme system
function M.get_flavor()
    local flavor_file = vim.fn.expand("~/.config/themes/current_flavor.txt")

    -- Check if file exists
    if vim.fn.filereadable(flavor_file) == 0 then
        -- File doesn't exist, return default
        return "mocha"
    end

    -- Read the file
    local file = io.open(flavor_file, "r")
    if not file then
        return "mocha"
    end

    local flavor = file:read("*line")
    file:close()

    -- Trim whitespace and validate
    if flavor then
        flavor = flavor:match("^%s*(.-)%s*$")  -- Trim whitespace

        -- Validate it's a valid Catppuccin flavor
        local valid_flavors = { mocha = true, latte = true, frappe = true, macchiato = true }
        if valid_flavors[flavor] then
            return flavor
        end
    end

    -- Fallback to mocha if invalid
    return "mocha"
end

return M

return {
    'lewis6991/gitsigns.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    config = function()
        require('gitsigns').setup({
            sign_priority = 20,
            current_line_blame = true,
            on_attach = function()
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                -- Actions
                map('n', '<leader>hs', gs.stage_hunk)
                map('n', '<leader>hr', gs.reset_hunk)
                map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('n', '<leader>hS', gs.stage_buffer)
                map('n', '<leader>hu', gs.undo_stage_hunk)
                map('n', '<leader>hR', gs.reset_buffer)
                map('n', '<leader>hp', gs.preview_hunk)
                map('n', '<leader>hb', function() gs.blame_line { full = true } end)
                map('n', '<leader>tb', gs.toggle_current_line_blame)

                -- Enhanced diff with Diffview integration
                map('n', '<leader>hd', function()
                  -- Use Diffview for better diff experience
                  local ok, _ = pcall(require, 'diffview')
                  if ok then
                    vim.cmd('DiffviewOpen')
                  else
                    gs.diffthis()
                  end
                end, { desc = 'Diff this (Diffview or Gitsigns)' })

                map('n', '<leader>hD', function()
                  local ok, _ = pcall(require, 'diffview')
                  if ok then
                    vim.cmd('DiffviewFileHistory %')
                  else
                    gs.diffthis('~')
                  end
                end, { desc = 'Diff file history (Diffview or Gitsigns)' })

                map('n', '<leader>td', gs.toggle_deleted)

                -- Text object
                map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end,
        })
    end,
}

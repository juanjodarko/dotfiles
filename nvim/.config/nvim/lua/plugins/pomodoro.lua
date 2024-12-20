-- local pomodoro = {
--     work_time = 25 * 60, -- Default work session duration in seconds
--     break_time = 5 * 60, -- Default break duration in seconds
--     timer_active = false,
--     timer = nil,
--     current_session = "work", -- "work" or "break"
--     time_left = 0
-- }
--
-- -- Utility function to update Lualine with remaining time
-- local function update_lualine()
--     if pomodoro.timer_active then
--         local minutes = math.floor(pomodoro.time_left / 60)
--         local seconds = pomodoro.time_left % 60
--         local session_type = (pomodoro.current_session == "work") and "Work" or "Break"
--         pomodoro.lualine_status = string.format("Pomodoro %s: %02d:%02d", session_type, minutes, seconds)
--     else
--         pomodoro.lualine_status = ""
--     end
--     vim.cmd('redrawstatus')
-- end
--
-- -- Custom Lualine component
-- local function pomodoro_status()
--     return pomodoro.lualine_status or ''
-- end
--
-- -- Start the Pomodoro timer
-- function pomodoro.start_timer()
--     pomodoro.timer_active = true
--     pomodoro.start_work_session()
--     update_lualine()
-- end
--
-- -- Stop the Pomodoro timer
-- function pomodoro.stop_timer()
--     if pomodoro.timer then
--         vim.fn.timer_stop(pomodoro.timer)
--     end
--     pomodoro.timer_active = false
--     pomodoro.timer = nil
--     pomodoro.time_left = 0
--     update_lualine()
-- end
--
-- -- Start a work session
-- function pomodoro.start_work_session()
--     if not pomodoro.timer_active then return end
--     pomodoro.current_session = "work"
--     pomodoro.time_left = pomodoro.work_time
--     pomodoro.timer = vim.fn.timer_start(1000, function()
--         pomodoro.time_left = pomodoro.time_left - 1
--         update_lualine()
--         if pomodoro.time_left <= 0 then
--             vim.notify("Work session ended. Time for a break!", vim.log.levels.INFO)
--             pomodoro.start_break_session()
--         end
--     end, { ["repeat"] = pomodoro.work_time })
-- end
--
-- -- Start a break session
-- function pomodoro.start_break_session()
--     if not pomodoro.timer_active then return end
--     pomodoro.current_session = "break"
--     pomodoro.time_left = pomodoro.break_time
--     pomodoro.timer = vim.fn.timer_start(1000, function()
--         pomodoro.time_left = pomodoro.time_left - 1
--         update_lualine()
--         if pomodoro.time_left <= 0 then
--             vim.notify("Break ended. Time to work!", vim.log.levels.INFO)
--             pomodoro.start_work_session()
--         end
--     end, { ["repeat"] = pomodoro.break_time })
-- end
--
-- -- Command to start the Pomodoro timer
-- vim.api.nvim_create_user_command('PomodoroStart', function()
--     pomodoro.start_timer()
-- end, {})
--
-- -- Command to stop the Pomodoro timer
-- vim.api.nvim_create_user_command('PomodoroStop', function()
--     pomodoro.stop_timer()
-- end, {})
--
-- -- Command to configure Pomodoro times
-- vim.api.nvim_create_user_command('PomodoroConfig', function(opts)
--     local args = vim.split(opts.args, " ")
--     if #args >= 2 then
--         pomodoro.work_time = tonumber(args[1]) * 60
--         pomodoro.break_time = tonumber(args[2]) * 60
--         vim.notify(string.format("Pomodoro configured: work time = %d minutes, break time = %d minutes", args[1], args
--             [2]))
--     else
--         vim.notify("Usage: PomodoroConfig <work_time_in_minutes> <break_time_in_minutes>")
--     end
-- end, { nargs = '*' })
--
-- -- Lualine setup with Pomodoro component
-- require('lualine').setup {
--     sections = {
--         lualine_c = { pomodoro_status }
--     }
-- }
--
-- return pomodoro
return {
    "epwalsh/pomo.nvim",
    version = "*", -- Recommended, use latest release instead of latest commit
    lazy = true,
    cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
    dependencies = {
        -- Optional, but highly recommended if you want to use the "Default" timer
        "rcarriga/nvim-notify",
    },
    opts = {
        {
            -- How often the notifiers are updated.
            update_interval = 1000,

            -- Configure the default notifiers to use for each timer.
            -- You can also configure different notifiers for timers given specific names, see
            -- the 'timers' field below.
            notifiers = {
                -- The "Default" notifier uses 'vim.notify' and works best when you have 'nvim-notify' installed.
                {
                    name = "Default",
                    opts = {
                        -- With 'nvim-notify', when 'sticky = true' you'll have a live timer pop-up
                        -- continuously displayed. If you only want a pop-up notification when the timer starts
                        -- and finishes, set this to false.
                        sticky = true,

                        -- Configure the display icons:
                        title_icon = "󱎫",
                        text_icon = "󰄉",
                        -- Replace the above with these if you don't have a patched font:
                        -- title_icon = "⏳",
                        -- text_icon = "⏱️",
                    },
                },

                -- The "System" notifier sends a system notification when the timer is finished.
                -- Available on MacOS and Windows natively and on Linux via the `libnotify-bin` package.
                { name = "System" },

                -- You can also define custom notifiers by providing an "init" function instead of a name.
                -- See "Defining custom notifiers" below for an example 👇
                -- { init = function(timer) ... end }
            },

            -- Override the notifiers for specific timer names.
            timers = {
                -- For example, use only the "System" notifier when you create a timer called "Break",
                -- e.g. ':TimerStart 2m Break'.
                Break = {
                    { name = "System" },
                },
            },
            -- You can optionally define custom timer sessions.
            sessions = {
                -- Example session configuration for a session called "pomodoro".
                pomodoro = {
                    { name = "Work",        duration = "25m" },
                    { name = "Short Break", duration = "5m" },
                    { name = "Work",        duration = "25m" },
                    { name = "Short Break", duration = "5m" },
                    { name = "Work",        duration = "25m" },
                    { name = "Long Break",  duration = "15m" },
                },
            },
        }
        -- See below for full list of options 👇
    },
}

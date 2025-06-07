local wezterm = require 'wezterm'
local M = {}

local project_dir = wezterm.home_dir .. '/code'

local function project_dirs()
    local projects = { wezterm.home_dir }

    -- Get top-level directories
    local handle = io.popen('ls -d ' .. project_dir .. '/* 2>/dev/null')
    if handle then
        for dir in handle:lines() do
            table.insert(projects, dir)

            -- Get one level deeper for each directory
            local sub_handle = io.popen('ls -d ' .. dir .. '/* 2>/dev/null')
            if sub_handle then
                for sub_dir in sub_handle:lines() do
                    table.insert(projects, sub_dir)
                end
                sub_handle:close()
            end
        end
        handle:close()
    end

    return projects
end

M.choose_project = function()
    local choices = {}
    for _, value in ipairs(project_dirs()) do
        table.insert(choices, { label = value })
    end

    return wezterm.action.InputSelector {
        title = 'Projects',
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(child_window, child_pane, id, label)
            if not label then
                return
            end

            -- Get the project name from the path
            local project_name = label:match("([^/]+)$")

            -- Switch to workspace
            child_window:perform_action(wezterm.action.SwitchToWorkspace {
                name = project_name,
                spawn = { cwd = label }
            }, child_pane)

            -- Set the tab title
            child_window:perform_action(wezterm.action.SetTabTitle(project_name), child_pane)
        end),
    }
end

return M

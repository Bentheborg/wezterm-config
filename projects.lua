local wezterm = require 'wezterm'
local platform = require 'platform'
local act = wezterm.action

local M = {}

local project_roots
local fd
local project_shell

if platform.is_windows then
    project_roots = { 'G:' }
    fd = 'fd.exe'

    project_shell = {
        'pwsh.exe',
        '-NoLogo',
    }
else
    project_roots = {
        wezterm.home_dir .. '/Projects',
        wezterm.home_dir .. '/Work',
    }
    fd = '/usr/bin/fd'

    project_shell = {
        'zsh',
        '-l',
    }
end

local project_ignores = {
    'node_modules',

    -- Ignore your FiveM build tree specifically
    '**/fivem/fivem/**',
    'Fivem source code',
    '**/build/**',
    '**/we-layerd/**'

    -- Examples:
    -- 'vendor',
    -- 'target',
    -- '.cache',
    -- 'some-folder/**',
    -- '**/generated/**',
}

local function normalize_path(path)
    return path
        :gsub('\\', '/')
        :gsub('/+$', '')
end

local normalized_project_roots = {}
for _, root in ipairs(project_roots) do
    table.insert(normalized_project_roots, (normalize_path(root)))
end

local function cache_signature()
    return table.concat(normalized_project_roots, '|')
        .. '||'
        .. table.concat(project_ignores, '|')
end

local function relative_path(path)
    local normalized = normalize_path(path)

    for _, root in ipairs(normalized_project_roots) do
        if normalized:sub(1, #root):lower() == root:lower() then
            return (normalized:sub(#root + 1):gsub('^/', ''))
        end
    end

    return normalized
end

local function add_project(projects, seen, path)
    local normalized = normalize_path(path)

    local key = platform.is_windows
        and normalized:lower()
        or normalized

    if seen[key] then
        return
    end

    seen[key] = true

    table.insert(projects, {
        id = normalized,
        label = relative_path(normalized),
    })
end

local function scan_projects()
    local projects = {}
    local seen = {}

    ------------------------------------------------------------------
    -- Keep existing behaviour:
    -- include immediate children of the main Projects directory.
    ------------------------------------------------------------------

    for _, root in ipairs(project_roots) do
        for _, path in ipairs(wezterm.glob(root .. '/*')) do
            add_project(projects, seen, path)
        end
    end

    ------------------------------------------------------------------
    -- Recursively discover Git repositories.
    ------------------------------------------------------------------

    local fd_args = {
        fd,
        '-H',
        '-I',
        '-a',
        '--prune',
    }

    for _, pattern in ipairs(project_ignores) do
        table.insert(fd_args, '--exclude')
        table.insert(fd_args, pattern)
    end

    table.insert(fd_args, [[^\.git$]])
    for _, root in ipairs(project_roots) do
        table.insert(fd_args, root)
    end

    local success, stdout, stderr =
        wezterm.run_child_process(fd_args)

    if not success then
        wezterm.log_error(
            'Failed to find git projects: ' .. tostring(stderr)
        )
    else
        for line in stdout:gmatch '[^\r\n]+' do
            local normalized = normalize_path(line)

            local repo = normalized:gsub('/%.git$', '')

            add_project(projects, seen, repo)
        end
    end

    table.sort(projects, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return projects
end

----------------------------------------------------------------------
-- Cache
----------------------------------------------------------------------

local function refresh_cache()
    local projects = scan_projects()

    wezterm.GLOBAL.project_cache = {
        signature = cache_signature(),
        projects = projects,
    }

    wezterm.log_info(
        'Project cache refreshed: '
        .. tostring(#projects)
        .. ' projects'
    )

    return projects
end

local function cached_projects(force_refresh)
    if force_refresh then
        return refresh_cache()
    end

    local cache = wezterm.GLOBAL.project_cache

    if cache
        and cache.signature == cache_signature()
        and cache.projects
    then
        return cache.projects
    end

    -- Fallback:
    --
    -- If gui-startup didn't populate the cache for some reason,
    -- populate it the first time the picker is opened.
    return refresh_cache()
end

----------------------------------------------------------------------
-- Project picker
----------------------------------------------------------------------

function M.choose_project(force_refresh)
    return wezterm.action_callback(function(window, pane)
        local choices = cached_projects(force_refresh == true)

        window:perform_action(
            act.InputSelector {
                title = force_refresh
                    and 'Projects (refreshed)'
                    or 'Projects',

                fuzzy = true,
                choices = choices,

                action = wezterm.action_callback(
                    function(inner_window, inner_pane, id, label)
                        if not id then
                            return
                        end

                        inner_window:perform_action(
                            act.SwitchToWorkspace {
                                name = label,
								spawn = {
									cwd = id,
									args = project_shell,
									domain = { DomainName = 'local' },
								},
                            },
                            inner_pane
                        )
                    end
                ),
            },
            pane
        )
    end)
end

----------------------------------------------------------------------
-- Startup
----------------------------------------------------------------------

function M.setup()
    wezterm.on('gui-startup', function()
        refresh_cache()
    end)
end

return M

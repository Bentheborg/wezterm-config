local wezterm = require 'wezterm'
local appearance = require 'appearance'

local M = {}

local git_cache = {}
local GIT_CACHE_SECONDS = 3

local function basename(path)
	if not path or path == '' then
		return nil
	end

	path = path:gsub('\\', '/'):gsub('/+$', '')

	return path:match('([^/]+)$') or path
end

local function cwd_details(pane)
	local vars = pane:get_user_vars()
	local cwd = vars.CWD

	if cwd and cwd ~= '' then
		return cwd, nil
	end

	-- Fallback only.
	local wez_cwd = pane:get_current_working_dir()

	if not wez_cwd then
		return nil, nil
	end

	if wez_cwd.file_path then
		return wez_cwd.file_path, wez_cwd.host
	end

	local ok, parsed = pcall(wezterm.url.parse, tostring(wez_cwd))

	if ok and parsed then
		return parsed.file_path, parsed.host
	end

	return tostring(wez_cwd), nil
end

local function git_info(cwd)
	if not cwd then
		return nil
	end

	local now = os.time()
	local cached = git_cache[cwd]

	if cached and now - cached.time < GIT_CACHE_SECONDS then
		return cached.value or nil
	end

	local ok, meta = wezterm.run_child_process {
		'git',
		'-C',
		cwd,
		'rev-parse',
		'--show-toplevel',
		'--abbrev-ref',
		'HEAD',
	}

	if not ok then
		git_cache[cwd] = {
			time = now,
			value = false,
		}

		return nil
	end

	local lines = {}

	for line in meta:gmatch '[^\r\n]+' do
		table.insert(lines, line)
	end

	if #lines < 2 then
		git_cache[cwd] = {
			time = now,
			value = false,
		}

		return nil
	end

	local branch = lines[2]

	local status_ok, status = wezterm.run_child_process {
		'git',
		'-C',
		cwd,
		'status',
		'--porcelain=v1',
		'--branch',
	}

	local dirty = 0
	local ahead = 0
	local behind = 0

	if status_ok then
		for line in status:gmatch '[^\r\n]+' do
			if line:sub(1, 2) == '##' then
				ahead = tonumber(line:match 'ahead (%d+)') or 0
				behind = tonumber(line:match 'behind (%d+)') or 0
			else
				dirty = dirty + 1
			end
		end
	end

	local value = {
		branch = branch,
		dirty = dirty,
		ahead = ahead,
		behind = behind,
	}

	git_cache[cwd] = {
		time = now,
		value = value,
	}

	return value
end

local function git_segment(info)
	if not info then
		return nil
	end

	local parts = {
		' ' .. info.branch,
	}

	if info.dirty == 0 then
		table.insert(parts, '✓')
	else
		table.insert(parts, ' ' .. info.dirty)
	end

	if info.ahead > 0 then
		table.insert(parts, '⇡' .. info.ahead)
	end

	if info.behind > 0 then
		table.insert(parts, '⇣' .. info.behind)
	end

	return table.concat(parts, ' ')
end

local function process_name(pane)
	local process = pane:get_foreground_process_name() or ''

	process = basename(process) or process
	process = process:lower():gsub('%.exe$', '')

	return process
end

local function detected_app(pane)
	local process = process_name(pane)
	local title = (pane:get_title() or ''):lower()
	local text = process .. ' ' .. title

	if text:find('claude', 1, true) then
		return '󰆍 Claude'
	end

	if text:find('codex', 1, true) then
		return '󰆍 Codex'
	end

	if text:find('lazygit', 1, true) then
		return ' Lazygit'
	end

	if process == 'nvim'
			or process == 'neovim'
			or text:find('neovim', 1, true)
	then
		return ' Neovim'
	end

	-- Don't waste status space on the normal shell.
	return nil
end

local function agent_state(pane)
	local path = wezterm.home_dir
			.. '/.wezterm-agent-state/'
			.. tostring(pane:pane_id())
			.. '.txt'

	local file = io.open(path, 'r')

	if not file then
		return nil
	end

	local data = file:read '*a'
	file:close()

	local agent, state, timestamp =
			data:match '^([^|]+)|([^|]+)|(%d+)%s*$'

	if not agent or not state or not timestamp then
		return nil
	end

	-- Ignore abandoned state from an old/crashed pane.
	if os.time() - tonumber(timestamp) > 43200 then
		return nil
	end

	local names = {
		claude = 'Claude',
		codex = 'Codex',
	}

	local icons = {
		running = '󰚩',
		asking = '',
		idle = '󰄬',
	}

	local name = names[agent]

	if not name then
		return nil
	end

	return string.format(
		'%s %s',
		icons[state] or '󰆍',
		name
	)
end

local function mode_segment(window)
	local key_table = window:active_key_table()

	if key_table then
		return '󰩨 ' .. key_table:gsub('_', ' '):upper()
	end

	if window:leader_is_active() then
		return '󰌌 LEADER'
	end

	return nil
end

local function is_zoomed(window)
	local tab = window:active_tab()

	for _, info in ipairs(tab:panes_with_info()) do
		if info.is_active and info.is_zoomed then
			return true
		end
	end

	return false
end

local function remote_segment(host)
	if not host or host == '' then
		return nil
	end

	local local_host = wezterm.hostname():lower()
	local remote_host = host:lower()

	if remote_host == local_host
			or remote_host == 'localhost'
	then
		return nil
	end

	return '󰢹 ' .. host
end

local function segments_for_right_status(window, pane)
	local segments = {}

	local function add(value)
		if value and value ~= '' then
			table.insert(segments, value)
		end
	end

	if is_zoomed(window) then
		add '󰊓 ZOOMED'
	end

	add(mode_segment(window))

	local cwd, host = cwd_details(pane)

	-- Current folder is ALWAYS the actual current directory.
	if cwd then
		local folder = basename(cwd)

		if folder then
			add(' ' .. folder)
		end
	end

	-- Project is ALWAYS the WezTerm workspace.
	-- Default workspace is intentionally hidden.
	local workspace = window:active_workspace()

	if workspace and workspace ~= 'default' then
		add('󰖲 ' .. workspace)
	end

	-- Git contributes branch/status only.
	local git = git_info(cwd)

	if git then
		add(git_segment(git))
	end

	add(agent_state(pane) or detected_app(pane))
	add(remote_segment(host))

	add(" "..wezterm.strftime '%a %b %-d %H:%M')

	return segments
end

function M.setup()
	wezterm.on('update-status', function(window, pane)
		local arrow = wezterm.nerdfonts.pl_right_hard_divider
		local segments = segments_for_right_status(window, pane)

		local palette = window:effective_config().resolved_palette
		local bg = wezterm.color.parse(palette.background)
		local fg = palette.foreground

		local gradient_to = bg
		local gradient_from

		if appearance.is_dark() then
			gradient_from = gradient_to:lighten(0.2)
		else
			gradient_from = gradient_to:darken(0.2)
		end

		local gradient = wezterm.color.gradient({
			orientation = 'Horizontal',
			colors = {
				gradient_from,
				gradient_to,
			},
		}, #segments)

		local elements = {}

		for i, segment in ipairs(segments) do
			if i == 1 then
				-- Explicit background fixes the white speck you found.
				table.insert(elements, {
					Background = {
						Color = palette.background,
					},
				})
			end

			table.insert(elements, {
				Foreground = {
					Color = gradient[i],
				},
			})

			table.insert(elements, {
				Text = arrow,
			})

			table.insert(elements, {
				Foreground = {
					Color = fg,
				},
			})

			table.insert(elements, {
				Background = {
					Color = gradient[i],
				},
			})

			table.insert(elements, {
				Text = ' ' .. segment .. ' ',
			})
		end

		window:set_right_status(
			wezterm.format(elements)
		)
	end)
end

return M

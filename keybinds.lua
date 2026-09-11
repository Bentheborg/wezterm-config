local wezterm = require("wezterm")
local projects = require("projects")
local platform = require("platform")
local background = require("background")
local M = {}


local function move_pane(key, direction)
	return {
		key = key,
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

local function getDir()
	return platform.is_windows and "G:\\0_Repos\\Configs" or "~/Projects/Configs"
end

M.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

M.keys = {
	{
		key = "y",
		mods = "LEADER",
		action = wezterm.action.QuickSelect,
	},
	{
		key = "b",
		mods = "LEADER",
		action = wezterm.action_callback(function(_, pane)
			background.cycle_pane(pane, 1)
		end),
	},
	{
		key = "B",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(_, pane)
			background.cycle_pane(pane, -1)
		end),
	},

	{
		key = "o",
		mods = "LEADER",
		action = wezterm.action.PaneSelect({
			alphabet = "123456789",
		}),
	},
	{
		key = "O",
		mods = "LEADER|SHIFT",
		action = wezterm.action.PaneSelect({
			alphabet = "123456789",
			mode = "SwapWithActive",
		}),
	},

	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local process = pane:get_foreground_process_name() or ""
			process = process:lower()

			if process:match("pwsh%.exe$") or process:match("powershell%.exe$") then
				window:perform_action(
					wezterm.action.SendKey({ key = "v", mods = "CTRL" }),
					pane
				)
			else
				window:perform_action(
					wezterm.action.PasteFrom("Clipboard"),
					pane
				)
			end
		end),
	},
	{
		key = "V",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		key = "v",
		mods = "CTRL|ALT",
		action = wezterm.action.SendKey({ key = "v", mods = "CTRL" }),
	},

	-- Ctrl+Shift+A selects the entire terminal scrollback.
	{
		key = "A",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.ActivateCopyMode, pane)

			wezterm.time.call_after(0.01, function()
				window:perform_action(
				wezterm.action.CopyMode("MoveToScrollbackTop"),
				pane
				)

				window:perform_action(
				wezterm.action.CopyMode({ SetSelectionMode = "Cell" }),
				pane
				)

				window:perform_action(
				wezterm.action.CopyMode("MoveToScrollbackBottom"),
				pane
				)
			end)
		end),
	},
		-- Ctrl+Shift+Left: enter copy mode and select the previous word.
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.ActivateCopyMode, pane)

			wezterm.time.call_after(0.01, function()
				window:perform_action(
				wezterm.action.CopyMode("MoveLeft"),
				pane
				)
				window:perform_action(
				wezterm.action.CopyMode({ SetSelectionMode = "Word" }),
				pane
				)
				window:perform_action(
				wezterm.action.CopyMode("MoveBackwardWord"),
				pane
				)
			end)
		end),
	},

	-- Ctrl+Shift+Right: enter copy mode and select the next word.
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.ActivateCopyMode, pane)

			wezterm.time.call_after(0.01, function()
				window:perform_action(
				wezterm.action.CopyMode({ SetSelectionMode = "Word" }),
				pane
				)
				window:perform_action(
				wezterm.action.CopyMode("MoveForwardWord"),
				pane
				)
				window:perform_action(
				wezterm.action.CopyMode("MoveLeft"),
				pane
				)

			end)
		end),
	},

	-- Ctrl+Shift+Up: enter copy mode and extend upward.
	{
		key = "UpArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.ActivateCopyMode, pane)

			wezterm.time.call_after(0.01, function()
				window:perform_action(
				wezterm.action.CopyMode({ SetSelectionMode = "Word" }),
				pane
				)
				window:perform_action(
				wezterm.action.CopyMode("MoveUp"),
				pane
				)
			end)
		end),
	},

	-- Ctrl+Shift+Down: enter copy mode and extend downward.
	{
		key = "DownArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.ActivateCopyMode, pane)

			wezterm.time.call_after(0.01, function()
				window:perform_action(
				wezterm.action.CopyMode({ SetSelectionMode = "Word" }),
				pane
				)
				window:perform_action(
				wezterm.action.CopyMode("MoveDown"),
				pane
				)
			end)
		end),
	},
	-- Edit this WezTerm config in Neovim.
	{
		key = ",",
		mods = "CTRL|ALT",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = getDir() .. "/wezterm/",
			args = {
				"nvim",
				".",
			},
		}),
	},
	-- Edit the Neovim config in Neovim.
	{
		key = ".",
		mods = "CTRL|ALT",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = getDir() .. "/nvim/",
			args = {
				"nvim",
				".",
			},
		}),
	},

	-- Alt+L opens a new tab in the current domain.
	{
		key = "l",
		mods = "ALT",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},

	-- Leader+t / Leader+q split the current pane in the two orientations.
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Right",
			command = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		key = "T",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Left",
			command = { domain = "CurrentPaneDomain" },
		}),
	},

	{
		key = "q",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Down",
			command = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		key = "Q",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Up",
			command = { domain = "CurrentPaneDomain" },
		}),
	},

	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- Ctrl+A, then Ctrl+A sends a real Ctrl+A through to the terminal.
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},

	-- Vim-style pane movement.
	move_pane("h", "Left"),
	move_pane("j", "Down"),
	move_pane("k", "Up"),
	move_pane("l", "Right"),

	-- Leader+r enters a short-lived resize mode; use h/j/k/l repeatedly.
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			one_shot = false,
			timeout_milliseconds = 1000,
		}),
	},

	-- Leader+p opens ~/Projects entries as workspaces.
	{
		key = "p",
		mods = "LEADER",
		action = projects.choose_project(),
	},
	-- Force-refresh project cache, then open search.
	{
		key = "P",
		mods = "LEADER",
		action = projects.choose_project(true),
	},

	-- Leader+f switches between existing WezTerm workspaces.
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
	{
		key = "R",
		mods = "LEADER",

		action = wezterm.action.PromptInputLine({
			description = "Rename workspace",

			action = wezterm.action_callback(function(window, pane, line)
				if not line or line == "" then
					return
				end

				local old_name = window:active_workspace()

				wezterm.mux.rename_workspace(old_name, line)
			end),
		}),
	},
	{
		key = "n",
		mods = "LEADER",

		action = wezterm.action.PromptInputLine({
			description = "Open/create workspace",

			action = wezterm.action_callback(function(window, pane, line)
				if not line or line == "" then
					return
				end

				window:perform_action(
					wezterm.action.SwitchToWorkspace({
						name = line,
					}),
					pane
				)
			end),
		}),
	},
	{
		key = "]",
		mods = "LEADER",
		action = wezterm.action.SwitchWorkspaceRelative(1),
	},

	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.SwitchWorkspaceRelative(-1),
	},

	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.ResetTerminal,
	},
}


if not platform.is_windows then
	table.insert(M.keys, {
		key = "LeftArrow",
		mods = "CTRL",
		action = wezterm.action.SendString("\x1bb"),
	})

	table.insert(M.keys, {
		key = "RightArrow",
		mods = "CTRL",
		action = wezterm.action.SendString("\x1bf"),
	})
end
-- ---------------------------------------------------------------------------
-- Windows-only launchers. Kept in the config but only registered when WezTerm
-- is actually running on Windows, so on Linux these keys stay free.
-- ---------------------------------------------------------------------------

if platform.is_windows then
	local windows_keys = {
		-- Alt+P opens a new PowerShell tab.
		{
			key = "p",
			mods = "ALT",
			action = wezterm.action.SpawnCommandInNewTab({
				args = { "pwsh.exe", "-NoLogo" },
			}),
		},
		-- Alt+C opens a new CMD tab.
		{
			key = "c",
			mods = "ALT",
			action = wezterm.action.SpawnCommandInNewTab({
				args = { "cmd.exe" },
			}),
		},

		-- psmux
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action.SpawnCommandInNewTab({
				domain = { DomainName = "local" },
				args = {
					"psmux.exe",
					"attach-session",
					"-t",
					"static_session",
				},
			}),
		},
		{
			key = "s",
			mods = "LEADER|SHIFT",
			action = wezterm.action.SpawnCommandInNewTab({
				domain = { DomainName = "local" },
				args = {
					"psmux.exe",
					"new-session",
					"-s",
					"static_session",
					"pwsh.exe",
				},
			}),
		},
	}

	for _, k in ipairs(windows_keys) do
		table.insert(M.keys, k)
	end
end

M.key_tables = {
	resize_panes = {
		resize_pane("h", "Left"),
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("l", "Right"),
	},

  copy_mode = {
	{
	  key = "LeftArrow",
	  mods = "CTRL|SHIFT",
	  action = wezterm.action.Multiple({
		wezterm.action.CopyMode("MoveBackwardWord"),
		wezterm.action.CopyMode("MoveLeft"),
	  }),
	},
	{
	  key = "RightArrow",
	  mods = "CTRL|SHIFT",
	  action = wezterm.action.CopyMode("MoveForwardWord"),
	},
	{
	  key = "UpArrow",
	  mods = "CTRL|SHIFT",
	  action = wezterm.action.CopyMode("MoveUp"),
	},
	{
	  key = "DownArrow",
	  mods = "CTRL|SHIFT",
	  action = wezterm.action.CopyMode("MoveDown"),
	},

	{
	  key = "C",
	  mods = "CTRL|SHIFT",
	  action = wezterm.action.Multiple({
		wezterm.action.CopyTo("ClipboardAndPrimarySelection"),
		wezterm.action.CopyMode("Close"),
	  }),
	},

	{
	  key = "Escape",
	  mods = "NONE",
	  action = wezterm.action.CopyMode("Close"),
	},
  },
}

return M

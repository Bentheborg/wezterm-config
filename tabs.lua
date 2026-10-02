local wezterm = require("wezterm")

local M = {}

local function basename(path)
	if not path then
		return nil
	end

	path = path:gsub("\\", "/")
	return path:match("([^/]+)$")
end

local function tab_name(tab)
	local pane = tab.active_pane

	-- Respect manually assigned tab names first.
	if tab.tab_title and tab.tab_title ~= "" then
		return tab.tab_title
	end

	local process = basename(pane.foreground_process_name or "") or ""
	process = process:lower():gsub("%.exe$", "")

	local title = (pane.title or ""):lower()

	-- Prefer recognising the actual application from either source.
	--
	-- This prevents Neovim helper processes such as
	-- lua-language-server.exe becoming the tab title.
	if process == "nvim" or process == "neovim" or title:find("nvim", 1, true) or title:find("neovim", 1, true) then
		return "nvim"
	end

	if process == "lazygit" or title:find("lazygit", 1, true) then
		return "lazygit"
	end

	if process == "claude" or title:find("claude", 1, true) then
		return "claude"
	end

	if process == "codex" or title:find("codex", 1, true) then
		return "codex"
	end

	if process == "pwsh" or process == "powershell" or title:find("powershell", 1, true) then
		return "pwsh"
	end

	if process == "zsh" then
		return "zsh"
	end

	if process == "cmd" then
		return "cmd"
	end

	-- LSP/helper processes shouldn't hijack the visible tab name.
	local helpers = {
		["lua-language-server"] = true,
		["rust-analyzer"] = true,
		["typescript-language-server"] = true,
		["clangd"] = true,
	}

	if helpers[process] then
		return "nvim"
	end

	-- Never fall back to the raw pane title, because that can be
	-- "C:\\Program Files\\PowerShell\\..." etc.
	if process ~= "" then
		return process
	end

	return "shell"
end

function M.setup(theme)
	wezterm.on("format-tab-title", function(tab, tabs)
		local bg = tab.is_active and theme.roles.surface or theme.roles.background
		local fg = tab.is_active and theme.roles.foreground or theme.roles.muted
		local title = string.format(" %s%d  %s ", tab.is_active and "▍" or " ", tab.tab_index + 1, tab_name(tab))

		return {
			{
				Background = {
					Color = bg,
				},
			},
			{
				Foreground = {
					Color = fg,
				},
			},
			{
				Text = title,
			},
		}
	end)
end

return M

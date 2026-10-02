local wezterm = require "wezterm"

local M = {}

local function theme(palette, generated)
	return {
		color_scheme = "Tokyo Night",
		colors = generated and palette or nil,
		roles = {
			background = palette.background,
			surface = generated and palette.tab_bar.active_tab.bg_color or palette.selection_bg,
			selection = palette.selection_bg,
			foreground = palette.foreground,
			muted = generated and palette.tab_bar.inactive_tab.fg_color or palette.brights[1],
			accent = palette.ansi[4],
			secondary = palette.ansi[7],
			error = palette.ansi[2],
		},
	}
end

local function valid(palette)
	if type(palette) ~= "table" then
		return false
	end
	for _, key in ipairs { "background", "foreground", "cursor_bg", "cursor_fg", "cursor_border", "selection_bg", "selection_fg" } do
		if type(palette[key]) ~= "string" or not palette[key]:match "^#%x%x%x%x%x%x$" then
			return false
		end
	end
	for _, key in ipairs { "ansi", "brights" } do
		if type(palette[key]) ~= "table" or #palette[key] ~= 8 then
			return false
		end
		for _, color in ipairs(palette[key]) do
			if type(color) ~= "string" or not color:match "^#%x%x%x%x%x%x$" then
				return false
			end
		end
	end
	if type(palette.tab_bar) ~= "table" then
		return false
	end
	for _, key in ipairs { "active_tab", "inactive_tab", "inactive_tab_hover" } do
		local tab = palette.tab_bar[key]
		if type(tab) ~= "table" then
			return false
		end
		for _, color in ipairs { tab.bg_color or "", tab.fg_color or "" } do
			if type(color) ~= "string" or not color:match "^#%x%x%x%x%x%x$" then
				return false
			end
		end
	end
	return type(palette.tab_bar.background) == "string" and palette.tab_bar.background:match "^#%x%x%x%x%x%x$" ~= nil
end

function M.current()
	local fallback = theme(wezterm.get_builtin_color_schemes()["Tokyo Night"], false)
	local home = os.getenv "HOME"
	if not wezterm.target_triple:find "linux" or not home then
		return fallback
	end

	local current = home .. "/.local/state/omarchy/current/"
	-- Watch the stable parent: Omarchy replaces the entire theme directory.
	wezterm.add_to_config_reload_watch_list(current)
	local file = io.open(current .. "theme/wezterm-colors.json", "r")
	if not file then
		return fallback
	end
	local data = file:read "*a"
	file:close()
	local ok, palette = pcall(wezterm.json_parse, data)
	if not ok or not valid(palette) then
		return fallback
	end
	return theme(palette, true)
end

return M

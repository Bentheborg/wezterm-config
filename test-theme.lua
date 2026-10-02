-- Run with: WEZTERM_EXPECT_BACKGROUND=#101010 wezterm --config-file ./test-theme.lua ls-fonts
-- Point HOME at an isolated fixture to check missing/invalid generated palettes.
local wezterm = require "wezterm"
local theme = require "theme"
local selected = theme.current()
local expected = assert(os.getenv "WEZTERM_EXPECT_BACKGROUND")
assert(selected.roles.background:lower() == expected:lower(), "Unexpected theme background")
assert(selected.color_scheme == "Tokyo Night", "Missing fallback base")

local triple = wezterm.target_triple
wezterm.target_triple = "x86_64-pc-windows-msvc"
assert(theme.current().colors == nil, "Windows must use Tokyo Night without Linux integration")
wezterm.target_triple = triple

return { color_scheme = selected.color_scheme, colors = selected.colors }

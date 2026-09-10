local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local background = require 'background'
local keybinds = require 'keybinds'
local status = require 'status'
local projects = require 'projects'
local appearance = require 'appearance'
local platform = require 'platform'

-- ---------------------------------------------------------------------------
-- Shell
-- ---------------------------------------------------------------------------

if platform.is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
else
  config.default_prog = { 'zsh', '-l' }
end

-- CMD / PowerShell entries only make sense on Windows; on Linux the single
-- zsh default is enough, so the launch menu is left unset.
if platform.is_windows then
  config.launch_menu = {
    {
      label = 'Command Prompt',
      args = { 'cmd.exe' },
    },
    {
      label = 'PowerShell',
      args = { 'pwsh.exe', '-NoLogo' },
    },
  }
end

-- ---------------------------------------------------------------------------
-- Your original visual style
-- ---------------------------------------------------------------------------

if appearance.is_dark() then
  config.color_scheme = 'Tokyo Night'
else
  config.color_scheme = 'Tokyo Night Day'
end

config.font = wezterm.font('Hack Nerd Font', { weight = 'DemiBold' })
config.font_size = 12
config.max_fps = 120
config.window_close_confirmation = "NeverPrompt"
config.default_cursor_style = "BlinkingBar"
config.unzoom_on_switch_pane = true
config.tab_max_width = 32

if platform.is_windows then
  config.window_decorations = 'RESIZE'
end

config.inactive_pane_hsb = {
  saturation = 0.95,
  brightness = 0.6,
}

-- Bring the tab bar back because the new status/workspace information lives
-- there, while keeping it restrained rather than using the big fancy tabs.
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

-- Monterey image + dark overlay (Windows only; see background.lua).
background.apply(config)

-- ---------------------------------------------------------------------------
-- New leader / pane / project / workspace controls
-- ---------------------------------------------------------------------------

config.leader = keybinds.leader
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables

-- Workspace + time + hostname powerline details on the right of the tab bar.
projects.setup()
status.setup()

return config

local wezterm = require 'wezterm'

return {
  is_windows = wezterm.target_triple:find('windows') ~= nil,
}

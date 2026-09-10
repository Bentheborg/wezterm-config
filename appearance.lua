local wezterm = require 'wezterm'
local M = {}

function M.is_dark()
  if wezterm.gui then
    local appearance = wezterm.gui.get_appearance()
    return appearance and appearance:find('Dark') ~= nil
  end

  return true
end

return M

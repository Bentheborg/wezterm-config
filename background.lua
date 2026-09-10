local wezterm = require 'wezterm'
local platform = require 'platform'
local M = {}

-- Monterey background + dark overlay design. Windows only.
local BACKGROUND_IMAGE = 'G:\\0_Repos\\Configs\\img\\bg-monterey.png'

local pane_backgrounds = {
  { colour = nil },       -- reset to configured theme
  { colour = '#171e2b' }, -- blue
  { colour = '#17251d' }, -- green
  { colour = '#221b2b' }, -- purple
  { colour = '#2b191b' }, -- red
}

local pane_background_state = {}

local function layers(focused)
  return {
    {
      source = {
        File = BACKGROUND_IMAGE,
      },
      hsb = {
        hue = 1.0,
        saturation = focused and 1.02 or 0.8,
        brightness = 0.05,
      },
      width = '100%',
      height = '100%',
    },
    {
      source = {
        Color = '#1b1d23',
      },
      width = '100%',
      height = '100%',
      opacity = 0.55,
    },
  }
end

function M.cycle_pane(pane, direction)
  local id = pane:pane_id()
  local current = pane_background_state[id] or 1
  local index = ((current - 1 + direction) % #pane_backgrounds) + 1

  pane_background_state[id] = index

  local colour = pane_backgrounds[index].colour

  if colour then
    pane:inject_output(string.format('\x1b]11;%s\x1b\\', colour))
  else
    pane:inject_output('\x1b]104\x1b\\')
  end
end

function M.apply(config)
  if not platform.is_windows then
    return
  end

  -- config.background = layers(true)

  -- wezterm.on('window-focus-changed', function(window, _pane)
  --   local overrides = window:get_config_overrides() or {}
  --   overrides.background = layers(window:is_focused())
  --   window:set_config_overrides(overrides)
  -- end)
end

return M
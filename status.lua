local wezterm = require 'wezterm'
local appearance = require 'appearance'
local M = {}

local function segments_for_right_status(window)
  local segments = {}

  local tab = window:active_tab()
  local panes = tab:panes_with_info()

  local zoomed = false

  for _, pane in ipairs(panes) do
    if pane.is_active and pane.is_zoomed then
      zoomed = true
      break
    end
  end

  if zoomed then
    table.insert(segments, '󰊓 ZOOMED')
  end

  table.insert(segments, window:active_workspace())
  table.insert(segments, wezterm.strftime('%a %b %-d %H:%M:%S'))
  table.insert(segments, wezterm.hostname())

  return segments
end

function M.setup()
  wezterm.on('update-status', function(window, pane)
    local arrow = wezterm.nerdfonts.pl_right_hard_divider
    local segments = segments_for_right_status(window)
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
      colors = { gradient_from, gradient_to },
    }, #segments)

    local elements = {}

    for i, segment in ipairs(segments) do
      if i == 1 then
        table.insert(elements, { Background = { Color = 'none' } })
      end

      table.insert(elements, { Foreground = { Color = gradient[i] } })
      table.insert(elements, { Text = arrow })
      table.insert(elements, { Foreground = { Color = fg } })
      table.insert(elements, { Background = { Color = gradient[i] } })
      table.insert(elements, { Text = ' ' .. segment .. ' ' })
    end

    window:set_right_status(wezterm.format(elements))
  end)
end

return M

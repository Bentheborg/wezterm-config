WEZTERM CONFIG
==============

Files:
  wezterm.lua      Main config
  platform.lua     OS detection helper (is_windows)
  background.lua    Monterey image / focus styling (Windows only)
  appearance.lua    OS light/dark helper used by the status gradient
  status.lua        Right-side workspace/time/hostname powerline status
  projects.lua      ~/Projects fuzzy project picker -> workspace
  keybinds.lua      Leader, panes, shell launchers, Ctrl+Arrow

Install (Linux / Omarchy):
  ~/.config/wezterm  ->  ~/Projects/Configs/wezterm   (symlink)

Main shortcuts:
  Ctrl+A, t          split pane
  Ctrl+A, q          split pane other direction
  Ctrl+A, h/j/k/l    move between panes
  Ctrl+A, r          resize mode; then h/j/k/l
  Ctrl+A, p          project picker (~/Projects)
  Ctrl+A, f          workspace picker
  Ctrl+A, Ctrl+A     send a literal Ctrl+A to the shell

  Ctrl+Alt+,         edit wezterm config in Neovim
  Ctrl+Alt+.         edit nvim config in Neovim
  Ctrl+Left/Right    previous/next word
  Ctrl+Shift+A       select entire scrollback

  Alt+L              new tab in the current domain

Windows-only (not registered on Linux):
  Alt+C              new CMD tab
  Alt+P              new PowerShell tab
  Ctrl+A, s / S      psmux attach / new-session

Notes:
  - The tab bar is intentionally enabled so the workspace/time/host status
    can be shown.
  - The Monterey background is only applied on Windows; on Linux the desktop
    theme shows through. The image path in background.lua is a Windows path
    and is only read there.

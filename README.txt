# WezTerm Config

A modular, keyboard-focused [WezTerm](https://wezterm.org/) configuration for Windows and Linux.

Built around fast pane management, project/workspace navigation, keyboard-driven selection, and a compact Tokyo Night interface.

## Features

* Cross-platform Windows and Linux configuration
* `Ctrl+A` leader key
* Vim-style pane navigation and resizing
* Directional pane splitting
* Number-based pane selection and swapping
* Per-pane background colour cycling
* Fuzzy project discovery with caching
* WezTerm workspace management
* Quick Select for URLs, paths, hashes and other terminal text
* Keyboard-driven scrollback selection
* Dynamic Tokyo Night light/dark colour scheme
* Powerline-style workspace, time and hostname status
* PowerShell / CMD shortcuts on Windows
* `psmux` integration on Windows

## Structure

```text
.
├── wezterm.lua       # Main configuration
├── keybinds.lua      # Keybindings, panes and workspace controls
├── projects.lua      # Project discovery, caching and fuzzy picker
├── background.lua    # Pane colours and optional window background
├── status.lua        # Right-side Powerline status
├── appearance.lua    # Light / dark appearance detection
└── platform.lua      # Platform detection
```

`wezterm.lua` acts as the entry point and loads the remaining modules.

## Requirements

| Dependency     | Purpose                             |
| -------------- | ----------------------------------- |
| WezTerm        | Terminal emulator                   |
| Hack Nerd Font | Main font and Nerd Font glyphs      |
| `fd`           | Recursive project discovery         |
| Neovim         | Config editing shortcuts            |
| PowerShell     | Default Windows shell               |
| Zsh            | Default Linux shell                 |
| `psmux`        | Optional Windows session management |

## Installation

Clone the repository so `wezterm.lua` lives inside WezTerm's config directory.

### Linux

```bash
git clone git@github.com:Bentheborg/wezterm-config.git ~/.config/wezterm
```

### Windows

```powershell
git clone git@github.com:Bentheborg/wezterm-config.git "$HOME\.config\wezterm"
```

Alternatively, clone it elsewhere and symlink the directory into `~/.config/wezterm`.

> [!NOTE]
> Some paths in this config are specific to my setup. See [Personal paths](#personal-paths) before using the config unchanged on another machine.

## Leader Key

The leader is:

```text
Ctrl+A
```

For example:

```text
Ctrl+A → t
```

means press `Ctrl+A`, release it, then press `t`.

Pressing `Ctrl+A` followed by `Ctrl+A` sends a literal `Ctrl+A` through to the active terminal.

## Keybindings

### Panes

| Binding            | Action                      |
| ------------------ | --------------------------- |
| `Leader + t`       | Split right                 |
| `Leader + T`       | Split left                  |
| `Leader + q`       | Split down                  |
| `Leader + Q`       | Split up                    |
| `Leader + h/j/k/l` | Move between panes          |
| `Leader + r`       | Enter pane resize mode      |
| `h/j/k/l`          | Resize while in resize mode |
| `Leader + z`       | Toggle pane zoom            |
| `Leader + o`       | Select pane by number       |
| `Leader + O`       | Swap with selected pane     |
| `Leader + b`       | Next pane background        |
| `Leader + B`       | Previous pane background    |

Pane backgrounds currently cycle through:

```text
Default → Blue → Green → Purple → Red
```

The colour is applied only to the selected pane, making it easier to visually separate shells, servers, logs, agents or other tasks within the same tab.

### Projects & Workspaces

| Binding      | Action                                |
| ------------ | ------------------------------------- |
| `Leader + p` | Open cached project picker            |
| `Leader + P` | Refresh project cache and open picker |
| `Leader + f` | Fuzzy workspace picker                |
| `Leader + n` | Open or create workspace              |
| `Leader + R` | Rename current workspace              |
| `Leader + [` | Previous workspace                    |
| `Leader + ]` | Next workspace                        |

The project picker discovers Git repositories recursively using `fd`, caches the results at startup, and opens the selected project as its own WezTerm workspace.

Current project roots:

```text
Windows
└── G:\

Linux
├── ~/Projects
└── ~/Work
```

Directories such as `node_modules` and configured build trees are excluded during discovery.

### Selection

| Binding              | Action                      |
| -------------------- | --------------------------- |
| `Leader + y`         | WezTerm Quick Select        |
| `Ctrl+Shift+A`       | Select entire scrollback    |
| `Ctrl+Shift+Left`    | Select previous word        |
| `Ctrl+Shift+Right`   | Select next word            |
| `Ctrl+Shift+Up/Down` | Extend selection vertically |
| `Ctrl+Shift+C`       | Copy and leave copy mode    |
| `Esc`                | Leave copy mode             |

Quick Select detects selectable terminal content such as URLs, paths, hashes and other common patterns without needing the mouse.

### Tabs & Config

| Binding      | Action                         |
| ------------ | ------------------------------ |
| `Alt+L`      | New tab in current pane domain |
| `Ctrl+Alt+,` | Open WezTerm config in Neovim  |
| `Ctrl+Alt+.` | Open Neovim config in Neovim   |
| `Leader + x` | Reset active terminal          |

### Windows Only

| Binding      | Action                    |
| ------------ | ------------------------- |
| `Alt+P`      | Open PowerShell tab       |
| `Alt+C`      | Open Command Prompt tab   |
| `Leader + s` | Attach to `psmux` session |
| `Leader + S` | Create `psmux` session    |

Linux also maps `Ctrl+Left` and `Ctrl+Right` to shell-compatible previous/next word movement.

## Appearance

The configuration automatically switches between:

```text
Dark  → Tokyo Night
Light → Tokyo Night Day
```

The main terminal font is:

```text
Hack Nerd Font DemiBold
12pt
```

Other visual settings include:

* 120 FPS maximum refresh
* blinking bar cursor
* dimmed inactive panes
* compact native tab bar
* Nerd Font Powerline status separators
* automatic unzoom when switching panes

The right side of the tab bar displays:

```text
[ZOOMED]  workspace  date/time  hostname
```

`ZOOMED` only appears while the active pane is zoomed.

## Backgrounds

`background.lua` contains two separate background systems.

### Pane backgrounds

Active panes can be individually colour-coded with:

```text
Leader + b
Leader + B
```

This uses terminal background escape sequences, so changing one pane does not change every other pane in the window.

### Window background

The config also contains an older Monterey image + dark overlay setup for Windows.

It is currently **disabled** in `background.lua`.

If re-enabled, its image path must be changed to a valid image on the target machine.

## Personal Paths

A few parts of the repository currently reflect my own filesystem layout.

### Project discovery

`projects.lua` currently scans:

```text
Windows: G:\
Linux:   ~/Projects
         ~/Work
```

Change `project_roots` in `projects.lua` to suit your machine.

### Config editing shortcuts

`keybinds.lua` currently expects the larger Configs repository at:

```text
Windows: G:\0_Repos\Configs
Linux:   ~/Projects/Configs
```

This is used by:

```text
Ctrl+Alt+,
Ctrl+Alt+.
```

Change `getDir()` if your configs live somewhere else.

### Monterey background

The optional Windows background currently references an image in my main Configs repository.

If you enable the background system, update `BACKGROUND_IMAGE` in `background.lua`.

## Project Picker

Project discovery runs once during WezTerm startup and stores the result in `wezterm.GLOBAL`.

Normal use:

```text
Leader + p
```

uses the cached list and opens instantly.

After creating or cloning a new project:

```text
Leader + P
```

forces a new filesystem scan before opening the picker.

Selecting a project creates or switches to a workspace whose working directory is that project.

## Platform Behaviour

### Windows

```text
Default shell: PowerShell
Project shell: PowerShell
Project root:  G:\
```

Windows-specific CMD, PowerShell and `psmux` bindings are registered only on Windows.

### Linux

```text
Default shell: Zsh
Project shell: Zsh
Project roots: ~/Projects, ~/Work
```

Windows-only bindings are not registered, leaving those keys available for other applications.

## Customisation

The config is intentionally split into small modules rather than keeping everything inside one large `wezterm.lua`.

Most changes should only require editing one file:

```text
Keybindings       → keybinds.lua
Project discovery → projects.lua
Pane backgrounds  → background.lua
Status bar        → status.lua
Theme detection   → appearance.lua
OS behaviour      → platform.lua
Core settings     → wezterm.lua
```

## License

Personal configuration provided as-is. Feel free to copy, modify and adapt it for your own setup.

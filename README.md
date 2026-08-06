# Config

## Installation

Capture the current live configuration before committing changes:

```bash
./sync.sh
```

The repository defines the sync scope. Every file represented under `config/`,
`local/`, and `bin/` is refreshed from its live counterpart under `~/.config/`,
`~/.local/`, `~/.local/bin/`, or the home directory. XCompose, Zsh's primary
configuration, and its custom theme use their conventional live locations and
are mapped explicitly. The `system/` tree maps to absolute paths below `/` and
stores application configuration overlays such as the customized Caelestia
QML. Package installation remains the responsibility of Archon.

No represented file is excluded. Credentials, histories, caches, generated
dependencies, and other private or transient files will be copied if they are
part of the repository's managed payload. Review `git diff` before committing
or pushing.
The installer creates a complete timestamped snapshot of every managed
destination under `~/.local/state/dotfiles-backups/` before it changes the live
configuration. System overlays are backed up below the same snapshot's
`system/` directory before being installed with `sudo`.

Run the complete desktop profile:

```bash
chmod +x install.sh
./install.sh
```

The default `--all` mode installs every tracked configuration, ensures the
Omarchy Quattro and Quickshell runtime is present, applies Catppuccin Mocha
with the Forest background, creates compatibility links for Hyprlock, installs
the Caelestia system overlays, and starts Caelestia as the default shell.

To choose individual components instead:

```bash
./install.sh --select
```

## Hyprland (Window Manager)

Prefix: `Super` (Windows/CMD key)

### Launch Applications

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Ghostty) |
| `Super + Shift + Return` | Alternative terminal (terax) |
| `Super + E` | File manager (yazi) |
| `Super + Shift + E` | File manager (nautilus) |
| `Super + W` | Browser (Zen) |
| `Super + Shift + W` | Private browser |
| `Super + R` | System monitor (btop) |
| `Super + Shift + R` | Mission Center |
| `Super + O` | Obsidian |
| `Super + P` | SCRCPY (phone mirror, screen off) |
| `Super + Shift + P` | SCRCPY (phone mirror, screen on) |
| `Super + C` | Code editor (Zed) |
| `Super + T` | T3 code |
| `Super + D` | Discord |
| `Super + S` | Spotify |
| `Super + M` | kew (terminal music) |
| `Super + Shift + M` | Cliamp (terminal music) |
| `Super + G` | Gapless music (GTK) |
| `Super + Alt + S` | LocalSend |
| `Super + I` | Settings (hyprmod) |
| `Alt + Space` | Vicinae (Raycast) |

### Window Management

| Key | Action |
|-----|--------|
| `Super + Q` | Close window |
| `Ctrl + Alt + Delete` | Close all windows |
| `Super + F` | Toggle floating |
| `Super + Shift + F` | Fullscreen |
| `Super + Ctrl + F` | Tiled fullscreen |
| `Super + Alt + F` | Full width |
| `Super + J` | Toggle window split |
| `Super + Z` | Toggle scratchpad |
| `Super + Shift + Z` | Move window to scratchpad |
| `Super + Ctrl + L` | Toggle workspace layout |

### Focus & Movement

| Key | Action |
|-----|--------|
| `Super + ←/→/↑/↓` | Move focus |
| `Super + Shift + ←/→/↑/↓` | Move window |
| `Super + Shift + Alt + ←/→/↑/↓` | Move workspace to monitor |
| `Alt + Tab` | Cycle to next window |
| `Alt + Shift + Tab` | Cycle to previous window |

### Workspaces

| Key | Action |
|-----|--------|
| `Super + 1-9,0` | Switch to workspace 1-10 |
| `Super + Shift + 1-9,0` | Move window to workspace 1-10 |
| `Super + Shift + Alt + 1-9,0` | Move window silently to workspace 1-10 |
| `Super + Tab` | Next workspace |
| `Super + Shift + Tab` | Previous workspace |
| `Super + Ctrl + Tab` | Former workspace |
| `Super + Scroll` | Scroll workspaces |

### Resizing

| Key | Action |
|-----|--------|
| `Super + -/= ` | Resize active window |
| `Super + Shift + -/= ` | Resize vertically |

### Window Groups

| Key | Action |
|-----|--------|
| `Super + Ctrl + G` | Toggle window grouping |
| `Super + Alt + G` | Move window out of group |
| `Super + Alt + ←/→/↑/↓` | Move window into group |
| `Super + Alt + Tab` | Next window in group |
| `Super + Alt + Shift + Tab` | Previous window in group |
| `Super + Ctrl + ←/→` | Navigate grouped windows |
| `Super + Alt + 1-5` | Switch to group window 1-5 |

### Utilities

| Key | Action |
|-----|--------|
| `Super + Space` | Omarchy menu |
| `Super + Escape` | Power menu |
| `Super + K` | Show keybindings |
| `Super + V` | Clipboard manager |
| `Super + ,` | Dismiss notification |
| `Super + Ctrl + ,` | Toggle silent notifications |
| `Super + Ctrl + E` | Emoji picker |
| `Super + Ctrl + C` | Screenshot menu |
| `Super + Ctrl + O` | Toggle Omarchy menu |
| `Super + Ctrl + I` | Toggle idle lock |
| `Super + Ctrl + N` | Toggle nightlight |
| `Super + Ctrl + S` | Toggle screensaver |
| `Super + Ctrl + W` | WiFi |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + A` | Audio (wireplumber) |
| `Super + Ctrl + M` | Monitor config |
| `Super + /` | Cycle monitor scaling |
| `Super + Shift + Space` | Toggle waybar |
| `Super + Ctrl + Space` | Background selector |
| `Super + Shift + Ctrl + Space` | Pick theme |
| `Super + Backspace` | Toggle window transparency |
| `Super + Shift + Backspace` | Toggle workspace gaps |
| `Super + Ctrl + Backspace` | Toggle single-window square aspect |

### Screen & Capture

| Key | Action |
|-----|--------|
| `Print` | Screenshot (built-in) |
| `Shift + Print` | Region screenshot (satty) |
| `Ctrl + Print` | Color picker |
| `Alt + Print` | Extract text |
| `Super + Print` | Screen recording |
| `Super + A` | Notification center |

### Lock & Session

| Key | Action |
|-----|--------|
| `Super + L` | Lock screen (hyprlock) |
| `Super + Shift + L` | Screensaver |

### Media Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute / switch audio output |
| `XF86AudioMicMute` | Mute microphone |
| `XF86AudioNext/Prev` | Next/previous track |
| `XF86AudioPlay/Pause` | Play/pause |
| `XF86MonBrightnessUp/Down` | Brightness up/down |
| `Super + PgUp/PgDn` | Brightness up/down |
| `Alt + Vol/Brightness` | 1% precise adjustment |

### Apple Display

| Key | Action |
|-----|--------|
| `Ctrl + F1` | Brightness down |
| `Ctrl + F2` | Brightness up |
| `Shift + Ctrl + F2` | Full brightness |

### Text Navigation (system-wide)

| Key | Action |
|-----|--------|
| `Alt + ←` | Home |
| `Alt + →` | End |
| `Alt + Shift + ←` | Select to start of line |
| `Alt + Shift + →` | Select to end of line |
| `Alt + Backspace` | Delete line backwards |
| `Alt + Delete` | Delete line forwards |

---

## Tmux

Prefix: `Ctrl+Space` (also `Ctrl+b` as fallback)

### Plugins

| Plugin | Key | Action |
|--------|-----|--------|
| [tmux-floax](https://github.com/omerxx/tmux-floax) | `Ctrl+f` | Toggle floating scratch terminal |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | `prefix + O` | Fuzzy session/window switcher |
| [tpm](https://github.com/tmux-plugins/tpm) | `prefix + I` | Install plugins |

### Panes

| Key | Action |
|-----|--------|
| `prefix + h` | Split vertically |
| `prefix + v` | Split horizontally |
| `prefix + x` | Kill pane |
| `Shift + ←/→/↑/↓` | Navigate panes |
| `Ctrl+Alt+Shift + ←/→/↑/↓` | Resize panes (5 units) |

### Windows

| Key | Action |
|-----|--------|
| `prefix + c` | New window (cwd) |
| `prefix + k` | Kill window |
| `prefix + r` | Rename window |
| `Alt + 1-9` | Switch to window 1-9 |

### Sessions

| Key | Action |
|-----|--------|
| `prefix + C` | New session (cwd) |
| `prefix + K` | Kill session |
| `prefix + R` | Rename session |
| `prefix + N` | Next session |
| `prefix + P` | Previous session |

### General

| Key | Action |
|-----|--------|
| `prefix + q` | Reload config |
| `Ctrl+p` | Command palette |
| `prefix + Space` | Send prefix |

### Sessionx (inside the picker)

| Key | Action |
|-----|--------|
| `Enter` | Accept / create session |
| `Ctrl+r` | Rename session |
| `Alt+Backspace` | Kill session |
| `Ctrl+w` | List all windows |
| `Ctrl+t` | Tree view |
| `Ctrl+e` | Expand PWD directories |
| `Ctrl+x` | Browse `~/.config` |
| `Ctrl+b` | Go back |
| `?` | Toggle preview |

---

## Neovim

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+q` | normal | Toggle sidebar (Neo-tree) |
| `Alt+↑/↓` | n,i,v | Move line up/down |
| `Alt+Shift+↑/↓` | n,i | Copy line up/down |
| `Alt+j/k` | n,i,v | Move line up/down |
| `Alt+←/→` | n,i,v | Go to start/end of line |
| `Alt+h/l` | n,i,v | Go to start/end of line |
| `Ctrl+~` | n,t | Toggle terminal (Snacks) |

---

## Zed

| Key | Action |
|-----|--------|
| `Ctrl+q` | Toggle left dock (file tree) |
| `Ctrl+b` | Toggle right dock |
| `Ctrl+Alt+Shift+q` | Quit Zed |
| `Alt+↑/↓` | Move line up/down |
| `Alt+Shift+↑/↓` | Duplicate line up/down |
| `Alt+Ctrl+Shift+↑/↓` | Add selection above/below |
| `Ctrl+Enter` | New line below |

---

## Ghostty (Terminal)

| Key | Action |
|-----|--------|
| `F11` | Toggle fullscreen |
| `Ctrl+v` | Paste from clipboard |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+l` | Clear screen |
| `Ctrl+Alt+↑/↓/←/→` | Go to split |
| `Ctrl+Shift+↑/↓/←/→` | New split |

---

## Shell (Zsh)

The shell profile uses Oh My Zsh with a Catppuccin Mocha prompt,
Fish-like autosuggestions and syntax highlighting, and additional completion
definitions. Machine-specific credentials belong in
`~/.config/zsh/private.zsh`; that file is never installed or committed.

### Aliases

| Alias | Command |
|-------|---------|
| `ss` | soft serve in homelab |
| `s` | ssh into homelab (uses mosh instead if ssh) |
| `q` | `exit` |
| `n` | `nvim` |
| `x` | `codex` |
| `oc` | `opencode` |
| `ocl` | `openclaude` |
| `cr` | `crush` |
| `u` | Full system update (pacman + yay + bun + flatpak) |
| `hyprmod` | Clone/run hyprmod settings editor |
| `y` | Yazi file manager (cd on exit) |
| `ff` | `fastfetch` |
| `t` | `tmux` |
| `c` | `clear` |
| `fk` | `thefuck` |
| `ls` | `ls` with `eza` (better styling) |
| `init` | `git init` |
| `add` | `git add .` |
| `branch` | `git branch -M main` |
| `commit <msg>` | `git commit -m <msg>` |
| `push` | `git push -u origin main` also pushes a commit directly with `git add .` if a string argument is passed. example: `push "commit message"` |

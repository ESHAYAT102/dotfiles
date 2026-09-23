# dotfiles

Personal configs for an Omarchy (Arch + Hyprland) setup. Everything installs
via `install.sh` — no manual copying needed.

## Usage

```bash
./install.sh                              # pick configs interactively
./install.sh --all                        # install everything
./install.sh --all --theme clouds         # install everything, Clouds theme
./install.sh --all --theme catppuccin     # install everything, Catppuccin Mocha
./install.sh --select --theme clouds      # pick configs, Clouds theme
```

Flags:

- `--all` — install every config below without prompting (default when no
  flag is given is the interactive picker, same as `--select`).
- `--select` — choose configs from a list (needs `gum`).
- `--theme <name>` — `clouds` or `catppuccin` (`catppuccin-mocha` also works).
  Picks the Omarchy theme plus the matching Ghostty, GTK, Yazi, and Zsh
  prompt themes. Omit it to keep whatever theme is active.

## What gets installed

| Name         | Destination(s)                                            |
| ------------ | --------------------------------------------------------- |
| Fastfetch    | `~/.config/fastfetch/`                                    |
| Zsh Shell    | `~/.zshrc`, `~/.oh-my-zsh/custom/`                        |
| Ghostty      | `~/.config/ghostty/`                                      |
| GTK          | `~/.config/gtk-3.0/gtk.css`, `~/.config/gtk-4.0/gtk.css`  |
| Herdr        | `~/.config/herdr/`                                        |
| Hyprland     | `~/.config/hypr/`                                         |
| Neovim       | `~/.config/nvim/`                                         |
| Omarchy      | `~/.config/omarchy/` (plugins, themes, hooks)             |
| Shell Extras | `~/.local/bin/`, `~/.config/systemd/user/`               |
| Tmux         | `~/.config/tmux/`, `~/.tmux.conf`                         |
| UWSM         | `~/.config/uwsm/`                                         |
| Vicinae      | `~/.config/vicinae/`, `~/.local/share/vicinae/`           |
| VSCode       | `~/.config/vscode/`                                       |
| Yazi         | `~/.config/yazi/`                                         |
| Zed          | `~/.config/zed/`, `~/.local/share/zed/`                   |
| XCompose     | `~/.XCompose`                                             |

Theme files live under `config/<app>/<theme>/` (e.g. `config/gtk/clouds/`,
`config/yazi/catppuccin-mocha/`); the installer copies the one matching
`--theme`.

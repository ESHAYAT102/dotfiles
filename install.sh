#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

THEME=""

usage() {
  echo "Usage: $0 [--all|--select] [--theme <name>]" >&2
  echo "  --theme: catppuccin or clouds (default: first found)" >&2
  exit 2
}

options=(
  "Fastfetch"
  "Zsh Shell"
  "Ghostty"
  "GTK"
  "Herdr"
  "Hyprland"
  "Neovim"
  "Omarchy"
  "Shell Extras"
  "Tmux"
  "UWSM"
  "Vicinae"
  "VSCode"
  "Yazi"
  "Zed"
  "XCompose"
)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      selected=("${options[@]}")
      shift
      ;;
    --select)
      readarray -t selected < <(printf '%s\n' "${options[@]}" | gum choose --no-limit --height 20 --header "Select configs to install:")
      shift
      ;;
    --theme)
      [[ $# -lt 2 ]] && usage
      THEME="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "${selected:-}" ]]; then
  readarray -t selected < <(printf '%s\n' "${options[@]}" | gum choose --no-limit --height 20 --header "Select configs to install:")
fi

if (( ${#selected[@]} == 0 )); then
  echo "Cancelled."
  exit 0
fi

install_fastfetch() {
  mkdir -p ~/.config/fastfetch
  cp config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
}

install_zsh() {
  local zsh_custom="$HOME/.oh-my-zsh/custom"

  command -v zsh >/dev/null 2>&1 || {
    echo "Zsh is required but is not installed."
    return 1
  }

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended
  fi

  mkdir -p "$zsh_custom/plugins" "$zsh_custom/themes" "$HOME/.config/zsh"
  for plugin in zsh-autosuggestions zsh-completions zsh-syntax-highlighting; do
    if [[ ! -d "$zsh_custom/plugins/$plugin/.git" ]]; then
      git clone --depth=1 "https://github.com/zsh-users/$plugin.git" "$zsh_custom/plugins/$plugin"
    fi
  done

  cp config/zsh/.zshrc "$HOME/.zshrc"

  local zsh_theme="omarchy"
  if [[ "$THEME" == "catppuccin" || "$THEME" == "catppuccin-mocha" ]]; then
    zsh_theme="catppuccin-mocha"
  fi
  sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$zsh_theme\"/" "$HOME/.zshrc"

  # Generate zsh theme from current Omarchy theme colors (if available)
  if [[ -x "$HOME/.config/omarchy/hooks/zsh-theme-from-theme" ]]; then
    "$HOME/.config/omarchy/hooks/zsh-theme-from-theme" 2>/dev/null || \
      cp config/zsh/catppuccin-mocha.zsh-theme "$zsh_custom/themes/omarchy.zsh-theme"
  else
    cp config/zsh/catppuccin-mocha.zsh-theme "$zsh_custom/themes/omarchy.zsh-theme"
  fi

  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
  fi
}

install_ghostty() {
  mkdir -p ~/.config/ghostty
  cp config/ghostty/config ~/.config/ghostty/config
}

install_gtk() {
  local gtk_theme="$THEME"
  case "$gtk_theme" in
    catppuccin|catppuccin-mocha) gtk_theme="catppuccin-mocha" ;;
    clouds) gtk_theme="clouds" ;;
    "")
      gtk_theme=$(find config/gtk -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | head -1)
      ;;
  esac
  if [[ -z $gtk_theme || ! -d "config/gtk/$gtk_theme" ]]; then
    echo "Warning: unknown GTK theme '$THEME', skipping" >&2
    return 0
  fi
  mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
  cp "config/gtk/$gtk_theme/gtk-3.0/gtk.css" ~/.config/gtk-3.0/gtk.css
  cp "config/gtk/$gtk_theme/gtk-4.0/gtk.css" ~/.config/gtk-4.0/gtk.css
  echo "GTK theme applied: $gtk_theme (reopen GTK apps to take effect)"
}

install_herdr() {
  mkdir -p ~/.config/herdr
  cp config/herdr/config.toml ~/.config/herdr/config.toml
}

install_hypr() {
  mkdir -p ~/.config/hypr/color
  cp config/hypr/autostart.lua ~/.config/hypr/autostart.lua
  cp config/hypr/bindings.lua ~/.config/hypr/bindings.lua
  cp config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua
  cp config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
  cp config/hypr/input.lua ~/.config/hypr/input.lua
  cp config/hypr/looknfeel.lua ~/.config/hypr/looknfeel.lua
  cp config/hypr/monitors.lua ~/.config/hypr/monitors.lua
  cp config/hypr/.luarc.json ~/.config/hypr/.luarc.json
  cp config/hypr/color/CMN141E.icc ~/.config/hypr/color/CMN141E.icc
}

install_nvim() {
  mkdir -p ~/.config/nvim
  cp -a config/nvim/. ~/.config/nvim/
}

install_omarchy() {
  mkdir -p ~/.config/omarchy
  # Drop destination symlinks shadowing paths we ship (e.g. Omarchy links
  # stock themes into ~/.local/share/omarchy); rm on a link removes only
  # the link, and cp would otherwise refuse to overwrite it with a directory.
  while IFS= read -r -d '' src; do
    dest="$HOME/.config/omarchy/${src#config/omarchy/}"
    [[ -L "$dest" ]] && rm -f "$dest"
  done < <(find config/omarchy -mindepth 1 -print0)
  cp -ra config/omarchy/. ~/.config/omarchy/

  # Install theme-sync hooks for shell prompt colors
  mkdir -p ~/.config/omarchy/hooks/theme-set.d
  cp config/omarchy/hooks/starship-from-theme ~/.config/omarchy/hooks/starship-from-theme
  cp config/omarchy/hooks/zsh-theme-from-theme ~/.config/omarchy/hooks/zsh-theme-from-theme
  chmod +x ~/.config/omarchy/hooks/starship-from-theme ~/.config/omarchy/hooks/zsh-theme-from-theme
  cp config/omarchy/hooks/starship-from-theme ~/.config/omarchy/hooks/theme-set.d/starship-from-theme
  cp config/omarchy/hooks/zsh-theme-from-theme ~/.config/omarchy/hooks/theme-set.d/zsh-theme-from-theme
  chmod +x ~/.config/omarchy/hooks/theme-set.d/starship-from-theme ~/.config/omarchy/hooks/theme-set.d/zsh-theme-from-theme

  local arcdock_dir="$HOME/.config/omarchy/plugins/io.github.claudsondouglas.arcdock"
  local arcdock_config="$HOME/.config/omarchy/arc-dock.json"
  local arcdock_raw="https://raw.githubusercontent.com/ESHAYAT102/archon/refs/heads/main/arcdock"
  if [[ -d "$arcdock_dir" ]]; then
    curl -fsSL "$arcdock_raw/Arcdock.qml" -o "$arcdock_dir/Arcdock.qml" 2>/dev/null || true
    curl -fsSL "$arcdock_raw/ArcSlot.qml" -o "$arcdock_dir/ArcSlot.qml" 2>/dev/null || true
  fi
  if [[ -f "$arcdock_config" ]]; then
    local arcdock_config_tmp
    arcdock_config_tmp=$(mktemp)
    jq '.settings.recentCount = 0' "$arcdock_config" > "$arcdock_config_tmp"
    mv "$arcdock_config_tmp" "$arcdock_config"
  fi

  local mission_control_dir="$HOME/.config/omarchy/plugins/io.github.andyweiboan.missioncontrol"
  local mission_control_patch="$SCRIPT_DIR/patches/mission-control.patch"
  if [[ -d "$mission_control_dir/.git" ]]; then
    if git -C "$mission_control_dir" apply --check "$mission_control_patch"; then
      git -C "$mission_control_dir" apply "$mission_control_patch"
    elif ! git -C "$mission_control_dir" apply --reverse --check "$mission_control_patch"; then
      echo "Warning: Mission Control customization does not match the installed version"
    fi
  fi

  if command -v voxtype >/dev/null 2>&1; then
    voxtype config set osd.enabled false >/dev/null 2>&1 || true
  fi

  # Keep Omarchy from starting its idle lock/screensaver and hide suspend.
  mkdir -p "$HOME/.local/state/omarchy/indicators"
  touch "$HOME/.local/state/omarchy/indicators/stay-awake"
  omarchy-toggle suspend-off 2>/dev/null || true

  if command -v omarchy >/dev/null 2>&1; then
    local theme_name
    if [[ -n "$THEME" ]]; then
      theme_name="$THEME"
    else
      theme_name=$(find config/omarchy/themes -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -1)
    fi
    if [[ -n $theme_name ]]; then
      omarchy theme set "$theme_name" || echo "Warning: failed to apply theme '$theme_name'"

      local theme_hypr="config/omarchy/themes/$theme_name/hyprland.lua"
      local state_dir="$HOME/.local/state/omarchy/current"
      if [[ -f "$theme_hypr" && -d "$state_dir/theme" ]]; then
        cp "$theme_hypr" "$state_dir/theme/hyprland.lua"
      fi
    fi
  fi
}

install_tmux() {
  mkdir -p ~/.config/tmux ~/.config/tmux-palette
  cp config/tmux/tmux.conf ~/.config/tmux/tmux.conf
  cp -r config/tmux/tmux-palette ~/.config/tmux/
  cp -r config/tmux-palette/* ~/.config/tmux-palette/
  chmod +x ~/.config/tmux/tmux-palette/bin/tmux-palette.sh
  touch ~/.tmux.conf
  grep -qxF 'source-file ~/.config/tmux/tmux.conf' ~/.tmux.conf || printf 'source-file ~/.config/tmux/tmux.conf\n' >> ~/.tmux.conf
}

install_uwsm() {
  mkdir -p ~/.config/uwsm
  cp config/uwsm/default ~/.config/uwsm/default
}

install_vicinae() {
  mkdir -p ~/.config/vicinae ~/.local/share/vicinae/shortcuts ~/.local/share/vicinae/extensions
  cp config/vicinae/settings.json ~/.config/vicinae/settings.json
  cp local/share/vicinae/shortcuts/shortcuts.json ~/.local/share/vicinae/shortcuts/shortcuts.json
  cp -r local/share/vicinae/extensions/. ~/.local/share/vicinae/extensions/
}

install_vscode() {
  mkdir -p ~/.config/vscode
  cp config/vscode/script.js ~/.config/vscode/script.js
  cp config/vscode/style.css ~/.config/vscode/style.css
}

install_yazi() {
  mkdir -p ~/.config/yazi
  cp config/yazi/theme.toml ~/.config/yazi/theme.toml
}

install_zed() {
  mkdir -p ~/.config/zed ~/.local/share/zed
  cp config/zed/keymap.json ~/.config/zed/keymap.json
  cp config/zed/settings.json ~/.config/zed/settings.json
  cp -r config/zed/themes/ ~/.config/zed/themes/
  cp -r local/share/zed/extensions/ ~/.local/share/zed/
}

install_xcompose() {
  cp config/XCompose ~/.XCompose
}

install_shell_extras() {
  mkdir -p ~/.local/bin ~/.config/systemd/user
  cp bin/herdr-tab-next ~/.local/bin/herdr-tab-next
  cp bin/herdr-tab-prev ~/.local/bin/herdr-tab-prev
  cp bin/omarchy-idle-inhibit-on-media ~/.local/bin/omarchy-idle-inhibit-on-media
  cp bin/confetti-fire ~/.local/bin/confetti-fire
  cp bin/confetti-nautilus-transfer ~/.local/bin/confetti-nautilus-transfer
  cp local/bin/omarchy-menu-emoji-insert ~/.local/bin/omarchy-menu-emoji-insert
  cp local/bin/omarchy-keybindings-toggle ~/.local/bin/omarchy-keybindings-toggle
  cp systemd/omarchy-idle-inhibit-on-media.service ~/.config/systemd/user/omarchy-idle-inhibit-on-media.service
  cp systemd/confetti-nautilus-transfer.service ~/.config/systemd/user/confetti-nautilus-transfer.service
  chmod +x ~/.local/bin/herdr-tab-next ~/.local/bin/herdr-tab-prev ~/.local/bin/omarchy-idle-inhibit-on-media ~/.local/bin/confetti-fire ~/.local/bin/confetti-nautilus-transfer ~/.local/bin/omarchy-menu-emoji-insert ~/.local/bin/omarchy-keybindings-toggle
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable omarchy-idle-inhibit-on-media.service 2>/dev/null || true
  systemctl --user enable --now confetti-nautilus-transfer.service 2>/dev/null || true
}

for opt in "${selected[@]}"; do
  case $opt in
    Fastfetch) install_fastfetch ;;
    "Zsh Shell") install_zsh ;;
    Ghostty) install_ghostty ;;
    GTK) install_gtk ;;
    Herdr) install_herdr ;;
    Hyprland) install_hypr ;;
    Neovim) install_nvim ;;
    Omarchy) install_omarchy ;;
    Tmux) install_tmux ;;
    UWSM) install_uwsm ;;
    Vicinae) install_vicinae ;;
    VSCode) install_vscode ;;
    Yazi) install_yazi ;;
    Zed) install_zed ;;
    XCompose) install_xcompose ;;
    "Shell Extras") install_shell_extras ;;
  esac
done

echo "Done! ${#selected[@]} config(s) installed."

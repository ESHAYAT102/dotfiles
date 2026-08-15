#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

options=(
  "Fastfetch"
  "Zsh Shell"
  "Ghostty"
  "Herdr"
  "Hyprland"
  "Neovim"
  "Omarchy"
  "Tmux"
  "UWSM"
  "Vicinae"
  "VSCode"
  "Yazi"
  "Zed"
  "XCompose"
)

case "${1:---all}" in
  --all)
    selected=("${options[@]}")
    ;;
  --select)
    readarray -t selected < <(printf '%s\n' "${options[@]}" | gum choose --no-limit --height 20 --header "Select configs to install:")
    ;;
  *)
    echo "Usage: $0 [--all|--select]" >&2
    exit 2
    ;;
esac

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
  cp config/zsh/catppuccin-mocha.zsh-theme "$zsh_custom/themes/catppuccin-mocha.zsh-theme"

  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
  fi
}

install_ghostty() {
  mkdir -p ~/.config/ghostty
  cp config/ghostty/config ~/.config/ghostty/config
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
  cp -ra config/omarchy/. ~/.config/omarchy/
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

for opt in "${selected[@]}"; do
  case $opt in
    Fastfetch) install_fastfetch ;;
    "Zsh Shell") install_zsh ;;
    Ghostty) install_ghostty ;;
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
  esac
done

echo "Done! ${#selected[@]} config(s) installed."

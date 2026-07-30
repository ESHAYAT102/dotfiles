#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

apply_omarchy_theme=false
install_full_profile=true

options=(
  "Fastfetch"
  "Fish Shell"
  "Ghostty"
  "Herdr"
  "Hyprland"
  "Neovim"
  "Omarchy"
  "Quickshell"
  "SwayNC"
  "SwayOSD"
  "Tmux"
  "UWSM"
  "Vicinae"
  "VSCode"
  "Waybar"
  "Yazi"
  "Zed"
  "Omarchy Shared"
  "Local Binaries"
  "XCompose"
)

case "${1:---all}" in
  --all)
    selected=("${options[@]}")
    ;;
  --select)
    install_full_profile=false
    readarray -t selected < <(printf '%s\n' "${options[@]}" | gum choose --no-limit --height 20 --header "Select configs to install:")
    ;;
  *)
    echo "Usage: $0 [--all|--select]" >&2
    exit 2
    ;;
esac

if (( ${#selected[@]} == 0 )); then
  gum style --foreground 9 "Cancelled."
  exit 0
fi

require_quattro_runtime() {
  local missing=()

  [[ -f /usr/share/omarchy/default/hypr/bootstrap.lua ]] || missing+=("omarchy-dev")
  command -v quickshell >/dev/null 2>&1 || missing+=("quickshell-git")
  [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]] || missing+=("polkit-gnome")

  if (( ${#missing[@]} > 0 )); then
    gum style --foreground 11 "Installing required desktop runtime: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi

  [[ -f /usr/share/omarchy/default/hypr/bootstrap.lua ]] || {
    gum style --foreground 9 "Missing /usr/share/omarchy/default/hypr/bootstrap.lua after runtime installation."
    exit 1
  }
}

install_fastfetch() {
  gum spin --title "Installing Fastfetch" -- mkdir -p ~/.config/fastfetch
  cp config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
}

install_fish() {
  gum spin --title "Installing Fish Shell" -- mkdir -p ~/.config/fish/functions
  cp config/fish/config.fish ~/.config/fish/config.fish
  cp config/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
}

install_ghostty() {
  gum spin --title "Installing Ghostty" -- mkdir -p ~/.config/ghostty
  cp config/ghostty/config ~/.config/ghostty/config
}

install_herdr() {
  gum spin --title "Installing Herdr" -- mkdir -p ~/.config/herdr
  cp config/herdr/config.toml ~/.config/herdr/config.toml
}

install_hypr() {
  gum spin --title "Installing Hyprland" -- mkdir -p ~/.config/hypr/icons ~/.config/hypr/scripts ~/.local/bin
  cp config/hypr/autostart.lua ~/.config/hypr/autostart.lua
  cp config/hypr/bindings.lua ~/.config/hypr/bindings.lua
  cp config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf
  cp config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua
  cp config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
  cp config/hypr/hyprsunset.conf ~/.config/hypr/hyprsunset.conf
  cp config/hypr/input.lua ~/.config/hypr/input.lua
  cp config/hypr/looknfeel.lua ~/.config/hypr/looknfeel.lua
  cp config/hypr/monitors.lua ~/.config/hypr/monitors.lua
  cp config/hypr/xdph.conf ~/.config/hypr/xdph.conf
  cp local/bin/xdph-no-picker ~/.local/bin/xdph-no-picker
  chmod +x ~/.local/bin/xdph-no-picker
  cp config/hypr/scripts/osd.sh ~/.config/hypr/scripts/osd.sh
  chmod +x ~/.config/hypr/scripts/osd.sh
  cp config/hypr/icons/*.svg ~/.config/hypr/icons/
}

install_nvim() {
  gum spin --title "Installing Neovim" -- mkdir -p ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins
  cp config/nvim/lua/config/keymaps.lua ~/.config/nvim/lua/config/keymaps.lua
  cp config/nvim/lua/config/options.lua ~/.config/nvim/lua/config/options.lua
  cp config/nvim/lua/plugins/*.lua ~/.config/nvim/lua/plugins/
}

install_omarchy() {
  gum spin --title "Installing Omarchy" -- mkdir -p ~/.config/omarchy/branding ~/.config/omarchy/hooks/post-update.d ~/.config/omarchy/hooks/post-boot.d ~/.config/omarchy/plugins ~/.config/omarchy/quattro-bar-only ~/.config/omarchy/extensions ~/.config/omarchy/themes ~/.config/systemd/user/omarchy-update-user-notify.service.d
  cp -r config/omarchy/branding/* ~/.config/omarchy/branding/
  cp config/omarchy/hooks/post-update.d/sync-dotfiles ~/.config/omarchy/hooks/post-update.d/sync-dotfiles
  cp -a config/omarchy/plugins/. ~/.config/omarchy/plugins/
  cp -a config/omarchy/quattro-bar-only/. ~/.config/omarchy/quattro-bar-only/
  cp -a config/omarchy/themes/. ~/.config/omarchy/themes/
  cp config/omarchy/shell.json ~/.config/omarchy/shell.json
  cp config/omarchy/shell.toml ~/.config/omarchy/shell.toml
  cp config/omarchy/extensions/omarchy-menu.jsonc ~/.config/omarchy/extensions/omarchy-menu.jsonc
  cp config/systemd/user/omarchy-update-user-notify.service.d/override.conf ~/.config/systemd/user/omarchy-update-user-notify.service.d/override.conf
  apply_omarchy_theme=true
}

install_quickshell() {
  require_quattro_runtime
  install_hypr
  install_omarchy
  install_swaync
  install_swayosd
  install_omarchy_shared
  install_localbin
  install_vicinae
  install_xcompose
}

install_omarchy_state_compatibility() {
  local config_current="$HOME/.config/omarchy/current"
  local state_current="$HOME/.local/state/omarchy/current"

  mkdir -p "$HOME/.config/omarchy" "$state_current/theme"

  if [[ -e $config_current && ! -L $config_current ]]; then
    mv "$config_current" "$config_current.pre-quattro.$(date +%s)"
  fi

  ln -sfn "$state_current" "$config_current"

  if [[ -f "$HOME/.config/omarchy/themes/catppuccin-mocha/hyprlock.conf" ]]; then
    cp "$HOME/.config/omarchy/themes/catppuccin-mocha/hyprlock.conf" "$state_current/theme/hyprlock.conf"
  fi
}

restart_custom_quickshell() {
  [[ -n ${WAYLAND_DISPLAY:-} ]] || return 0

  pkill -TERM -x waybar 2>/dev/null || true
  pkill -TERM -x quickshell 2>/dev/null || true
  setsid -f env \
    OMARCHY_PATH="$HOME/.config/omarchy/quattro-bar-only" \
    quickshell -n -p "$HOME/.config/omarchy/quattro-bar-only/shell"
}

install_swaync() {
  gum spin --title "Installing SwayNC" -- mkdir -p ~/.config/swaync
  cp config/swaync/config.json ~/.config/swaync/config.json
  cp config/swaync/style.css ~/.config/swaync/style.css
}

install_swayosd() {
  gum spin --title "Installing SwayOSD" -- mkdir -p ~/.config/swayosd
  cp config/swayosd/config.toml ~/.config/swayosd/config.toml
  cp config/swayosd/style.css ~/.config/swayosd/style.css
}

install_tmux() {
  gum spin --title "Installing Tmux" -- mkdir -p ~/.config/tmux ~/.config/tmux-palette
  cp config/tmux/tmux.conf ~/.config/tmux/tmux.conf
  cp -r config/tmux/tmux-palette ~/.config/tmux/
  cp -r config/tmux-palette/* ~/.config/tmux-palette/
  chmod +x ~/.config/tmux/tmux-palette/bin/tmux-palette.sh
  touch ~/.tmux.conf
  grep -qxF 'source-file ~/.config/tmux/tmux.conf' ~/.tmux.conf || printf 'source-file ~/.config/tmux/tmux.conf\n' >> ~/.tmux.conf
}

install_uwsm() {
  gum spin --title "Installing UWSM" -- mkdir -p ~/.config/uwsm
  cp config/uwsm/default ~/.config/uwsm/default
  cp config/uwsm/env ~/.config/uwsm/env
}

install_vicinae() {
  gum spin --title "Installing Vicinae" -- mkdir -p ~/.config/vicinae ~/.local/share/vicinae/shortcuts ~/.local/share/vicinae/extensions
  cp config/vicinae/settings.json ~/.config/vicinae/settings.json
  cp local/share/vicinae/shortcuts/shortcuts.json ~/.local/share/vicinae/shortcuts/shortcuts.json
  cp -r local/share/vicinae/extensions/. ~/.local/share/vicinae/extensions/
  systemctl --user daemon-reload
  systemctl --user enable --now vicinae.service
}

install_vscode() {
  gum spin --title "Installing VSCode" -- mkdir -p ~/.config/vscode
  cp config/vscode/script.js ~/.config/vscode/script.js
  cp config/vscode/style.css ~/.config/vscode/style.css
  if [[ -x ~/.config/omarchy/hooks/post-boot.d/vscode-theme ]]; then
    ~/.config/omarchy/hooks/post-boot.d/vscode-theme
  fi
}

install_waybar() {
  gum spin --title "Installing Waybar" -- mkdir -p ~/.config/waybar
  cp config/waybar/config.jsonc ~/.config/waybar/config.jsonc
  cp config/waybar/style.css ~/.config/waybar/style.css
}

install_yazi() {
  gum spin --title "Installing Yazi" -- mkdir -p ~/.config/yazi
  cp config/yazi/theme.toml ~/.config/yazi/theme.toml
}

install_zed() {
  gum spin --title "Installing Zed" -- mkdir -p ~/.config/zed
  cp config/zed/keymap.json ~/.config/zed/keymap.json
  cp config/zed/settings.json ~/.config/zed/settings.json
  cp -r local/share/zed/extensions/ ~/.local/share/zed/
}

install_omarchy_shared() {
  gum spin --title "Installing Omarchy Shared" -- mkdir -p ~/.local/bin
  cp local/share/omarchy/bin/omarchy-powerprofiles-set ~/.local/bin/omarchy-powerprofiles-set
  chmod +x ~/.local/bin/omarchy-powerprofiles-set
}

install_localbin() {
  gum spin --title "Installing Local Binaries" -- mkdir -p ~/.local/bin
  cp local/bin/area-screenshot ~/.local/bin/area-screenshot
  cp local/bin/screenshot ~/.local/bin/screenshot
  cp local/bin/xdph-no-picker ~/.local/bin/xdph-no-picker
  cp bin/omarchy-quattro-plymouth-switcher ~/.local/bin/omarchy-quattro-plymouth-switcher
  cp bin/omarchy-shell ~/.local/bin/omarchy-shell
  cp bin/omarchy-menu ~/.local/bin/omarchy-menu
  cp bin/omarchy-font-current ~/.local/bin/omarchy-font-current
  cp bin/omarchy-font-set ~/.local/bin/omarchy-font-set
  cp bin/omarchy-quattro-selector ~/.local/bin/omarchy-quattro-selector
  cp bin/omarchy-quattro-toggle ~/.local/bin/omarchy-quattro-toggle
  cp bin/omarchy-menu-keybindings ~/.local/bin/omarchy-menu-keybindings
  chmod +x ~/.local/bin/area-screenshot ~/.local/bin/screenshot ~/.local/bin/xdph-no-picker ~/.local/bin/omarchy-quattro-plymouth-switcher ~/.local/bin/omarchy-quattro-selector ~/.local/bin/omarchy-quattro-toggle ~/.local/bin/omarchy-shell ~/.local/bin/omarchy-menu ~/.local/bin/omarchy-menu-keybindings ~/.local/bin/omarchy-font-current ~/.local/bin/omarchy-font-set
}

install_xcompose() {
  gum spin --title "Installing XCompose" -- cp XCompose ~/.XCompose
  systemctl --user daemon-reload
  if ! systemctl --user cat omarchy-fcitx5.service >/dev/null 2>&1; then
    mkdir -p ~/.config/systemd/user
    cp config/systemd/user/omarchy-fcitx5.service ~/.config/systemd/user/omarchy-fcitx5.service
    systemctl --user daemon-reload
  fi
  systemctl --user enable --now omarchy-fcitx5.service
}

for opt in "${selected[@]}"; do
  case $opt in
    Fastfetch) install_fastfetch ;;
    "Fish Shell") install_fish ;;
    Ghostty) install_ghostty ;;
    Herdr) install_herdr ;;
    Hyprland) install_hypr ;;
    Neovim) install_nvim ;;
    Omarchy) install_omarchy ;;
    Quickshell) install_quickshell ;;
    SwayNC) install_swaync ;;
    SwayOSD) install_swayosd ;;
    Tmux) install_tmux ;;
    UWSM) install_uwsm ;;
    Vicinae) install_vicinae ;;
    VSCode) install_vscode ;;
    Waybar) install_waybar ;;
    Yazi) install_yazi ;;
    Zed) install_zed ;;
    "Omarchy Shared") install_omarchy_shared ;;
    "Local Binaries") install_localbin ;;
    XCompose) install_xcompose ;;
  esac
done

if $apply_omarchy_theme; then
  omarchy theme set catppuccin-mocha
  omarchy theme bg set "$HOME/.config/omarchy/themes/catppuccin-mocha/backgrounds/Forest.jpg"
  install_omarchy_state_compatibility
fi

if command -v nmcli >/dev/null 2>&1; then
  while IFS=: read -r uuid type; do
    [[ $type == "802-11-wireless" ]] || continue
    nmcli connection modify uuid "$uuid" connection.autoconnect yes connection.autoconnect-priority 100 connection.autoconnect-retries 0
  done < <(nmcli -t -f UUID,TYPE connection show)
fi

gsettings set org.gtk.gtk4.Settings.Debug enable-inspector-keybinding false
gsettings set org.gtk.Settings.Debug enable-inspector-keybinding false

if $install_full_profile; then
  restart_custom_quickshell
fi

gum style --foreground 10 "Done! ${#selected[@]} config(s) installed."

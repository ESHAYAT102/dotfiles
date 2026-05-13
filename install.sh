#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

options=(
  "Fastfetch"
  "Fish Shell"
  "Ghostty"
  "Hyprland"
  "Neovim"
  "Omarchy"
  "SwayNC"
  "SwayOSD"
  "Tmux"
  "UWSM"
  "VSCode"
  "Waybar"
  "Yazi"
  "Zed"
  "Omarchy Shared"
  "Local Binaries"
  "XCompose"
)

readarray -t selected < <(printf '%s\n' "${options[@]}" | gum choose --no-limit --height 20 --header "Select configs to install:")

if [ -z "$selected" ]; then
  gum style --foreground 9 "Cancelled."
  exit 0
fi

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

install_hypr() {
  gum spin --title "Installing Hyprland" -- mkdir -p ~/.config/hypr/icons ~/.config/hypr/scripts
  cp config/hypr/autostart.conf ~/.config/hypr/autostart.conf
  cp config/hypr/bindings.conf ~/.config/hypr/bindings.conf
  cp config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf
  cp config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
  cp config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
  cp config/hypr/hyprsunset.conf ~/.config/hypr/hyprsunset.conf
  cp config/hypr/input.conf ~/.config/hypr/input.conf
  cp config/hypr/looknfeel.conf ~/.config/hypr/looknfeel.conf
  cp config/hypr/mocha.conf ~/.config/hypr/mocha.conf
  cp config/hypr/monitors.conf ~/.config/hypr/monitors.conf
  cp config/hypr/xdph.conf ~/.config/hypr/xdph.conf
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
  gum spin --title "Installing Omarchy" -- mkdir -p ~/.config/omarchy/branding
  cp -r config/omarchy/branding/* ~/.config/omarchy/branding/
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
  if command -v bun >/dev/null 2>&1; then
    (cd ~/.config/tmux/tmux-palette && bun install --frozen-lockfile)
  else
    gum style --foreground 11 "Bun not found; tmux-palette needs Bun to run."
  fi
  touch ~/.tmux.conf
  grep -qxF 'source-file ~/.config/tmux/tmux.conf' ~/.tmux.conf || printf 'source-file ~/.config/tmux/tmux.conf\n' >> ~/.tmux.conf
}

install_uwsm() {
  gum spin --title "Installing UWSM" -- mkdir -p ~/.config/uwsm
  cp config/uwsm/default ~/.config/uwsm/default
}

install_vscode() {
  gum spin --title "Installing VSCode" -- mkdir -p ~/.config/vscode
  cp config/vscode/script.js ~/.config/vscode/script.js
  cp config/vscode/style.css ~/.config/vscode/style.css
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
  gum spin --title "Installing Omarchy Shared" -- mkdir -p ~/.local/share/omarchy/default/hypr/bindings ~/.local/share/omarchy/bin
  cp local/share/omarchy/default/hypr/apps.conf ~/.local/share/omarchy/default/hypr/apps.conf
  cp local/share/omarchy/default/hypr/autostart.conf ~/.local/share/omarchy/default/hypr/autostart.conf
  cp local/share/omarchy/default/hypr/bindings.conf ~/.local/share/omarchy/default/hypr/bindings.conf
  cp local/share/omarchy/default/hypr/envs.conf ~/.local/share/omarchy/default/hypr/envs.conf
  cp local/share/omarchy/default/hypr/input.conf ~/.local/share/omarchy/default/hypr/input.conf
  cp local/share/omarchy/default/hypr/looknfeel.conf ~/.local/share/omarchy/default/hypr/looknfeel.conf
  cp local/share/omarchy/default/hypr/windows.conf ~/.local/share/omarchy/default/hypr/windows.conf
  cp local/share/omarchy/default/hypr/bindings/clipboard.conf ~/.local/share/omarchy/default/hypr/bindings/clipboard.conf
  cp local/share/omarchy/default/hypr/bindings/media.conf ~/.local/share/omarchy/default/hypr/bindings/media.conf
  cp local/share/omarchy/default/hypr/bindings/tiling.conf ~/.local/share/omarchy/default/hypr/bindings/tiling.conf
  cp local/share/omarchy/default/hypr/bindings/tiling-v2.conf ~/.local/share/omarchy/default/hypr/bindings/tiling-v2.conf
  cp local/share/omarchy/default/hypr/bindings/utilities.conf ~/.local/share/omarchy/default/hypr/bindings/utilities.conf
  cp local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle ~/.local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle
  cp local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle ~/.local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle
  chmod +x ~/.local/share/omarchy/bin/omarchy-*
}

install_localbin() {
  gum spin --title "Installing Local Binaries" -- mkdir -p ~/.local/bin
  cp local/bin/area-screenshot ~/.local/bin/area-screenshot
  cp local/bin/screenshot ~/.local/bin/screenshot
  chmod +x ~/.local/bin/area-screenshot ~/.local/bin/screenshot
}

install_xcompose() {
  gum spin --title "Installing XCompose" -- cp XCompose ~/.XCompose
  cp local/share/omarchy/default/xcompose ~/.local/share/omarchy/default/xcompose
}

for opt in "${selected[@]}"; do
  case $opt in
    Fastfetch) install_fastfetch ;;
    "Fish Shell") install_fish ;;
    Ghostty) install_ghostty ;;
    Hyprland) install_hypr ;;
    Neovim) install_nvim ;;
    Omarchy) install_omarchy ;;
    SwayNC) install_swaync ;;
    SwayOSD) install_swayosd ;;
    Tmux) install_tmux ;;
    UWSM) install_uwsm ;;
    VSCode) install_vscode ;;
    Waybar) install_waybar ;;
    Yazi) install_yazi ;;
    Zed) install_zed ;;
    "Omarchy Shared") install_omarchy_shared ;;
    "Local Binaries") install_localbin ;;
    XCompose) install_xcompose ;;
  esac
done

gum style --foreground 10 "Done! ${#selected[@]} config(s) installed."

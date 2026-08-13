#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

apply_omarchy_theme=false
install_full_profile=true
backup_root="$HOME/.local/state/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

options=(
  "Fastfetch"
  "Zsh Shell"
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

backup_current_profile() {
  local path relative
  local paths=(
    "$HOME/.XCompose"
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.config/fastfetch"
    "$HOME/.config/fish"
    "$HOME/.config/ghostty"
    "$HOME/.config/herdr"
    "$HOME/.config/hypr"
    "$HOME/.config/nvim"
    "$HOME/.config/omarchy"
    "$HOME/.config/swaync"
    "$HOME/.config/swayosd"
    "$HOME/.config/systemd/user"
    "$HOME/.config/tmux"
    "$HOME/.config/tmux-palette"
    "$HOME/.config/uwsm"
    "$HOME/.config/vicinae"
    "$HOME/.config/vscode"
    "$HOME/.config/waybar"
    "$HOME/.config/yazi"
    "$HOME/.config/zed"
    "$HOME/.local/bin"
    "$HOME/.local/share/vicinae"
    "$HOME/.local/share/zed"
    "$HOME/.local/share/omarchy/bin/omarchy-powerprofiles-set"
  )

  mkdir -p "$backup_root"
  for path in "${paths[@]}"; do
    [[ -e $path || -L $path ]] || continue
    relative=${path#"$HOME"/}
    mkdir -p "$backup_root/$(dirname "$relative")"
    cp -a "$path" "$backup_root/$relative"
  done
  printf 'Pre-install backup: %s\n' "$backup_root"
}

backup_current_profile

restore_complete_snapshot() {
  local source_dir name

  for source_dir in "$SCRIPT_DIR"/config/*; do
    [[ -d $source_dir ]] || continue
    name=${source_dir##*/}
    [[ $name == zsh ]] && continue
    mkdir -p "$HOME/.config/$name"
    cp -a "$source_dir/." "$HOME/.config/$name/"
  done

  mkdir -p "$HOME/.local/bin" "$HOME/.local/share"
  cp -a "$SCRIPT_DIR/local/bin/." "$HOME/.local/bin/"
  cp -a "$SCRIPT_DIR/local/share/." "$HOME/.local/share/"
  install -Dm644 "$SCRIPT_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  install -Dm644 "$SCRIPT_DIR/config/XCompose" "$HOME/.XCompose"
}

enable_snapshot_services() {
  local units=(
    elephant.service
    omarchy-battery-monitor.timer
    omarchy-fcitx5.service
    omarchy-quickshell.service
    omarchy-recover-internal-monitor.service
    swayosd-server.service
    t3code.service
    voxtype.service
  )

  systemctl --user daemon-reload
  for unit in "${units[@]}"; do
    [[ -f "$HOME/.config/systemd/user/$unit" ]] || continue
    systemctl --user enable "$unit"
  done
}

install_system_overlays() {
  local source_file relative target backup_target

  [[ -d "$SCRIPT_DIR/system" ]] || return 0

  while IFS= read -r -d '' source_file; do
    relative=${source_file#"$SCRIPT_DIR/system/"}
    target="/$relative"
    backup_target="$backup_root/system/$relative"
    if [[ -e $target || -L $target ]]; then
      mkdir -p "$(dirname "$backup_target")"
      cp -a "$target" "$backup_target"
    fi
    sudo install -Dm644 "$source_file" "$target"
  done < <(find "$SCRIPT_DIR/system" -type f -print0)
}

require_quattro_runtime() {
  local missing=()

  [[ -f /usr/share/omarchy/default/hypr/bootstrap.lua ]] || missing+=("omarchy-dev")
  command -v quickshell >/dev/null 2>&1 || missing+=("quickshell-git")
  command -v nmcli >/dev/null 2>&1 || missing+=("networkmanager")
  [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]] || missing+=("polkit-gnome")
  command -v qrencode >/dev/null 2>&1 || missing+=("qrencode")

  if (( ${#missing[@]} > 0 )); then
    gum style --foreground 9 "Missing desktop runtime: ${missing[*]}"
    gum style --foreground 11 "Install packages through Archon, then rerun the dotfiles installer."
    exit 1
  fi

  [[ -f /usr/share/omarchy/default/hypr/bootstrap.lua ]] || {
    gum style --foreground 9 "Missing /usr/share/omarchy/default/hypr/bootstrap.lua after runtime installation."
    exit 1
  }

  sudo systemctl enable --now NetworkManager.service
}

install_fastfetch() {
  gum spin --title "Installing Fastfetch" -- mkdir -p ~/.config/fastfetch
  cp config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
}

install_zsh() {
  local zsh_custom="$HOME/.oh-my-zsh/custom"

  command -v zsh >/dev/null 2>&1 || {
    gum style --foreground 9 "Zsh is required but is not installed."
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
  gum spin --title "Installing Ghostty" -- mkdir -p ~/.config/ghostty
  cp config/ghostty/config ~/.config/ghostty/config
}

install_herdr() {
  gum spin --title "Installing Herdr" -- mkdir -p ~/.config/herdr
  cp config/herdr/config.toml ~/.config/herdr/config.toml
}

install_scroll_overview() {
  local repo_url="https://github.com/yayuuu/hyprland-scroll-overview.git"
  local plugin_state

  plugin_state="$(hyprpm list 2>/dev/null | sed $'s/\033\\[[0-9;]*m//g' || true)"

  if ! grep -q "Repository hyprland-scroll-overview" <<<"$plugin_state"; then
    hyprpm add "$repo_url"
    hyprpm update
    plugin_state="$(hyprpm list 2>/dev/null | sed $'s/\033\\[[0-9;]*m//g' || true)"
  fi

  if ! grep -A2 "Repository hyprland-scroll-overview" <<<"$plugin_state" | grep -q "enabled: true"; then
    hyprpm enable scrolloverview
  fi
  hyprpm reload
}

install_hypr() {
  gum spin --title "Installing Hyprland" -- mkdir -p ~/.config/hypr/color ~/.config/hypr/icons ~/.config/hypr/scripts ~/.local/bin ~/.local/lib ~/.local/share
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
  cp config/hypr/color/CMN141E.icc ~/.config/hypr/color/CMN141E.icc
  cp local/bin/xdph-no-picker ~/.local/bin/xdph-no-picker
  chmod +x ~/.local/bin/xdph-no-picker
  cp local/bin/hyprland-load-plugins ~/.local/bin/hyprland-load-plugins
  mkdir -p ~/.config/systemd/user
  cp config/systemd/user/omarchy-quickshell.service ~/.config/systemd/user/omarchy-quickshell.service
  systemctl --user daemon-reload
  systemctl --user enable --now voxtype.service omarchy-quickshell.service
  chmod +x ~/.local/bin/hyprland-load-plugins
  cp config/hypr/scripts/osd.sh ~/.config/hypr/scripts/osd.sh
  chmod +x ~/.config/hypr/scripts/osd.sh
  cp config/hypr/icons/*.svg ~/.config/hypr/icons/
  install_scroll_overview
}

install_nvim() {
  gum spin --title "Installing Neovim" -- mkdir -p ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins
  cp config/nvim/lua/config/keymaps.lua ~/.config/nvim/lua/config/keymaps.lua
  cp config/nvim/lua/config/options.lua ~/.config/nvim/lua/config/options.lua
  cp config/nvim/lua/config/remote_clipboard.lua ~/.config/nvim/lua/config/remote_clipboard.lua
  cp -a config/nvim/lua/plugins/*.lua ~/.config/nvim/lua/plugins/
}

install_omarchy() {
  gum spin --title "Installing Omarchy" -- mkdir -p ~/.config/omarchy/branding ~/.config/omarchy/hooks/post-update.d ~/.config/omarchy/hooks/post-boot.d ~/.config/omarchy/plugins ~/.config/omarchy/extensions ~/.config/omarchy/themes ~/.config/systemd/user/omarchy-update-user-notify.service.d
  cp -r config/omarchy/branding/* ~/.config/omarchy/branding/
  cp config/omarchy/hooks/post-update.d/sync-dotfiles ~/.config/omarchy/hooks/post-update.d/sync-dotfiles
  cp -a config/omarchy/plugins/. ~/.config/omarchy/plugins/
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

  if [[ -x "$HOME/.local/bin/desktop-shell-toggle" ]]; then
    "$HOME/.local/bin/desktop-shell-toggle" caelestia
  fi
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
  cp config/yazi/theme.template.toml ~/.config/yazi/theme.template.toml
  cp config/yazi/theme.template.toml ~/.config/yazi/theme.toml
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
  cp local/bin/opencode-display-screenshot ~/.local/bin/opencode-display-screenshot
  cp local/bin/xdph-no-picker ~/.local/bin/xdph-no-picker
  cp bin/omarchy-quattro-plymouth-switcher ~/.local/bin/omarchy-quattro-plymouth-switcher
  cp bin/omarchy-shell ~/.local/bin/omarchy-shell
  cp bin/omarchy-menu ~/.local/bin/omarchy-menu
  cp bin/omarchy-font-current ~/.local/bin/omarchy-font-current
  cp bin/omarchy-font-set ~/.local/bin/omarchy-font-set
  cp bin/omarchy-quattro-selector ~/.local/bin/omarchy-quattro-selector
  cp bin/omarchy-quattro-toggle ~/.local/bin/omarchy-quattro-toggle
  cp bin/omarchy-menu-keybindings ~/.local/bin/omarchy-menu-keybindings
  cp bin/omarchy-network-password ~/.local/bin/omarchy-network-password
  cp bin/omarchy-network-qr ~/.local/bin/omarchy-network-qr
  cp bin/omarchy-webapp-remove ~/.local/bin/omarchy-webapp-remove
  chmod +x ~/.local/bin/area-screenshot ~/.local/bin/screenshot ~/.local/bin/opencode-display-screenshot ~/.local/bin/xdph-no-picker ~/.local/bin/omarchy-quattro-plymouth-switcher ~/.local/bin/omarchy-quattro-selector ~/.local/bin/omarchy-quattro-toggle ~/.local/bin/omarchy-shell ~/.local/bin/omarchy-menu ~/.local/bin/omarchy-menu-keybindings ~/.local/bin/omarchy-network-password ~/.local/bin/omarchy-network-qr ~/.local/bin/omarchy-webapp-remove ~/.local/bin/omarchy-font-current ~/.local/bin/omarchy-font-set
}

install_xcompose() {
  gum spin --title "Installing XCompose" -- cp config/XCompose ~/.XCompose
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
    "Zsh Shell") install_zsh ;;
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

if $install_full_profile; then
  restore_complete_snapshot
  install_system_overlays
  enable_snapshot_services
fi

# Keep Ghostty's terminal palette synchronized with Caelestia's generated
# wallpaper scheme. The service creates the initial palette at login and the
# path unit refreshes it after subsequent wallpaper changes.
if [[ -x "$HOME/.local/bin/caelestia-ghostty-theme" && \
      -f "$HOME/.config/systemd/user/caelestia-ghostty-theme.service" && \
      -f "$HOME/.config/systemd/user/caelestia-ghostty-theme.path" ]]; then
  "$HOME/.local/bin/caelestia-ghostty-theme"
  systemctl --user daemon-reload
  systemctl --user enable --now caelestia-ghostty-theme.service caelestia-ghostty-theme.path
fi

if $apply_omarchy_theme; then
  install_omarchy_state_compatibility
  omarchy theme set catppuccin-mocha
  omarchy theme bg set "$HOME/.config/omarchy/themes/catppuccin-mocha/backgrounds/Forest.jpg"
  # Prevent Omarchy's first-login finalizer from reapplying Tokyo Night.
  mkdir -p "$HOME/.local/state/omarchy"
  touch "$HOME/.local/state/omarchy/finalize-user.done"
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
  mkdir -p "$HOME/.local/state"
  printf 'omarchy\n' > "$HOME/.local/state/desktop-shell-mode"
  "$HOME/.local/bin/desktop-shell-toggle" omarchy
fi

gum style --foreground 10 "Done! ${#selected[@]} config(s) installed."

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}
                  _            _       _
   ___  ___ _   _| |_       __| | ___ | |_ ___ 
  / _ \\/ __| | | | __|____ / _\` |/ _ \\| __/ __|
 |  __/\\__ \\ |_| | ||_____| (_| | (_) | |_\\__ \\
  \\___||___/\\__, |\\__|     \\__,_|\\___/ \\__|___/
            |___/ ${NC}
"

echo -e "${BOLD}Available configs:${NC}"
echo -e "  ${GREEN}1${NC}) Fastfetch"
echo -e "  ${GREEN}2${NC}) Fish Shell"
echo -e "  ${GREEN}3${NC}) Ghostty"
echo -e "  ${GREEN}4${NC}) Hyprland"
echo -e "  ${GREEN}5${NC}) Neovim"
echo -e "  ${GREEN}6${NC}) Omarchy"
echo -e "  ${GREEN}7${NC}) SwayNC"
echo -e "  ${GREEN}8${NC}) SwayOSD"
echo -e "  ${GREEN}9${NC}) Tmux"
echo -e " ${GREEN}10${NC}) UWSM"
echo -e " ${GREEN}11${NC}) Walker"
echo -e " ${GREEN}12${NC}) Waybar"
echo -e " ${GREEN}13${NC}) Yazi"
echo -e " ${GREEN}14${NC}) Zed"
echo -e " ${GREEN}15${NC}) Omarchy Shared"
echo -e " ${GREEN}16${NC}) Local Binaries"
echo -e " ${GREEN}17${NC}) XCompose"
echo ""
echo -e "Enter numbers (e.g. ${YELLOW}1 3 5${NC} or ${YELLOW}all${NC}), or ${RED}q${NC} to quit: "
read -r input

if [[ "$input" =~ ^[Qq](uit)?$ ]]; then
  echo -e "${YELLOW}Bye!${NC}"
  exit 0
fi

if [[ "$input" =~ ^[Aa][Ll][Ll]$ ]]; then
  selected=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17)
else
  selected=()
  for num in $input; do
    if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= 17 )); then
      selected+=("$num")
    fi
  done
fi

if [ ${#selected[@]} -eq 0 ]; then
  echo -e "${YELLOW}No valid selections. Bye!${NC}"
  exit 0
fi

install_fastfetch() {
  mkdir -p ~/.config/fastfetch
  cp config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
}

install_fish() {
  mkdir -p ~/.config/fish/functions
  cp config/fish/config.fish ~/.config/fish/config.fish
  cp config/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
}

install_ghostty() {
  mkdir -p ~/.config/ghostty
  cp config/ghostty/config ~/.config/ghostty/config
}

install_hypr() {
  mkdir -p ~/.config/hypr/icons
  mkdir -p ~/.config/hypr/scripts
  
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
  mkdir -p ~/.config/nvim/lua/config
  cp config/nvim/lua/config/keymaps.lua ~/.config/nvim/lua/config/keymaps.lua
  cp config/nvim/lua/config/options.lua ~/.config/nvim/lua/config/options.lua
}

install_omarchy() {
  mkdir -p ~/.config/omarchy/branding
  cp -r config/omarchy/branding/* ~/.config/omarchy/branding/
}

install_swaync() {
  mkdir -p ~/.config/swaync
  cp config/swaync/config.json ~/.config/swaync/config.json
  cp config/swaync/style.css ~/.config/swaync/style.css
}

install_swayosd() {
  mkdir -p ~/.config/swayosd
  cp config/swayosd/config.toml ~/.config/swayosd/config.toml
  cp config/swayosd/style.css ~/.config/swayosd/style.css
}

install_tmux() {
  mkdir -p ~/.config/tmux
  cp config/tmux/tmux.conf ~/.config/tmux/tmux.conf
}

install_uwsm() {
  mkdir -p ~/.config/uwsm
  cp config/uwsm/default ~/.config/uwsm/default
}

install_walker() {
  mkdir -p ~/.config/walker
  cp config/walker/config.toml ~/.config/walker/config.toml
}

install_waybar() {
  mkdir -p ~/.config/waybar
  cp config/waybar/config.jsonc ~/.config/waybar/config.jsonc
  cp config/waybar/style.css ~/.config/waybar/style.css
}

install_yazi() {
  mkdir -p ~/.config/yazi
  cp config/yazi/theme.toml ~/.config/yazi/theme.toml
}

install_zed() {
  mkdir -p ~/.config/zed
  cp config/zed/keymap.json ~/.config/zed/keymap.json
  cp config/zed/settings.json ~/.config/zed/settings.json
  cp -r local/share/zed/extensions/ ~/.local/share/zed/
}

install_omarchy_shared() {
  mkdir -p ~/.local/share/omarchy/default/hypr/bindings
  mkdir -p ~/.local/share/omarchy/bin
  
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
  
  cp local/share/omarchy/bin/omarchy-menu ~/.local/share/omarchy/bin/omarchy-menu
  cp local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle ~/.local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle
  cp local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle ~/.local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle
  chmod +x ~/.local/share/omarchy/bin/omarchy-*
}

install_localbin() {
  mkdir -p ~/.local/bin
  cp local/bin/area-screenshot ~/.local/bin/area-screenshot
  cp local/bin/screenshot ~/.local/bin/screenshot
  chmod +x ~/.local/bin/area-screenshot
  chmod +x ~/.local/bin/screenshot
}

install_xcompose() {
  cp XCompose ~/.XCompose
  cp local/share/omarchy/default/xcompose ~/.local/share/omarchy/default/xcompose
}

echo ""
for num in "${selected[@]}"; do
  case $num in
    1) install_fastfetch ;;
    2) install_fish ;;
    3) install_ghostty ;;
    4) install_hypr ;;
    5) install_nvim ;;
    6) install_omarchy ;;
    7) install_swaync ;;
    8) install_swayosd ;;
    9) install_tmux ;;
   10) install_uwsm ;;
   11) install_walker ;;
   12) install_waybar ;;
   13) install_yazi ;;
   14) install_zed ;;
   15) install_omarchy_shared ;;
   16) install_localbin ;;
   17) install_xcompose ;;
  esac
done

echo -e "${GREEN}Done! ${#selected[@]} config(s) installed.${NC}"

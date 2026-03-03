#!/bin/bash

# Create directories that don't exist
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/hypr/icons
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/.config/swaync
mkdir -p ~/.config/uwsm
mkdir -p ~/.config/yazi
mkdir -p ~/.config/zed
mkdir -p ~/.local/bin

# --- Fastfetch ---
cp config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

# --- Fish ---
cp config/fish/config.fish ~/.config/fish/config.fish
cp config/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish

# --- Ghostty ---
cp config/ghostty/config ~/.config/ghostty/config

# --- Hyprland ---
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

# Hyprland Icons
cp config/hypr/icons/brightness-down.svg ~/.config/hypr/icons/brightness-down.svg
cp config/hypr/icons/brightness-up.svg ~/.config/hypr/icons/brightness-up.svg
cp config/hypr/icons/mic-muted.svg ~/.config/hypr/icons/mic-muted.svg
cp config/hypr/icons/mic.svg ~/.config/hypr/icons/mic.svg
cp config/hypr/icons/volume-down.svg ~/.config/hypr/icons/volume-down.svg
cp config/hypr/icons/volume-muted.svg ~/.config/hypr/icons/volume-muted.svg
cp config/hypr/icons/volume-unmute.svg ~/.config/hypr/icons/volume-unmute.svg
cp config/hypr/icons/volume-up.svg ~/.config/hypr/icons/volume-up.svg
cp config/hypr/icons/eye.svg ~/.config/hypr/icons/eye.svg
cp config/hypr/icons/eye-off.svg ~/.config/hypr/icons/eye-off.svg
cp config/hypr/icons/lock.svg ~/.config/hypr/icons/lock.svg
cp config/hypr/icons/screensaver.svg ~/.config/hypr/icons/screensaver.svg
cp config/hypr/icons/battery.svg ~/.config/hypr/icons/battery.svg
cp config/hypr/icons/clock.svg ~/.config/hypr/icons/clock.svg
cp config/hypr/icons/desktop.svg ~/.config/hypr/icons/desktop.svg

# --- Neovim ---
cp config/nvim/lua/config/keymaps.lua ~/.config/nvim/lua/config/keymaps.lua
cp config/nvim/lua/config/options.lua ~/.config/nvim/lua/config/options.lua

# --- Omarchy Branding ---
cp -r config/omarchy/branding ~/.config/omarchy/

# --- Omarchy Branding ---
cp config/omarchy/branding/about.txt ~/.config/omarchy/branding/about.txt
cp config/omarchy/branding/arch_mini.txt ~/.config/omarchy/branding/arch_mini.txt
cp config/omarchy/branding/arch.txt ~/.config/omarchy/branding/arch.txt
cp config/omarchy/branding/esh.txt ~/.config/omarchy/branding/esh.txt
cp config/omarchy/branding/omarchy.txt ~/.config/omarchy/branding/omarchy.txt
cp config/omarchy/branding/screensaver_og.txt ~/.config/omarchy/branding/screensaver_og.txt
cp config/omarchy/branding/screensaver.txt ~/.config/omarchy/branding/screensaver.txt

# --- Notifications & OSD ---
cp config/swaync/config.json ~/.config/swaync/config.json
cp config/swaync/style.css ~/.config/swaync/style.css
cp config/swayosd/config.toml ~/.config/swayosd/config.toml
cp config/swayosd/style.css ~/.config/swayosd/style.css

# --- Walker & Waybar ---
cp config/walker/config.toml ~/.config/walker/config.toml
cp config/waybar/config.jsonc ~/.config/waybar/config.jsonc
cp config/waybar/style.css ~/.config/waybar/style.css

# --- Walker & Waybar ---
cp config/uwsm/default ~/.config/uwsm/default

# --- Yazi & Zed ---
cp config/yazi/theme.toml ~/.config/yazi/theme.toml
cp config/zed/keymap.json ~/.config/zed/keymap.json
cp config/zed/settings.json ~/.config/zed/settings.json

# --- Local Binaries ---
cp local/bin/area-screenshot ~/.local/bin/area-screenshot
cp local/bin/screenshot ~/.local/bin/screenshot
chmod +x ~/.local/bin/area-screenshot
chmod +x ~/.local/bin/screenshot

# Omarchy Shared Core Files
cp local/share/omarchy/default/hypr/apps.conf ~/.local/share/omarchy/default/hypr/apps.conf
cp local/share/omarchy/default/hypr/autostart.conf ~/.local/share/omarchy/default/hypr/autostart.conf
cp local/share/omarchy/default/hypr/bindings.conf ~/.local/share/omarchy/default/hypr/bindings.conf
cp local/share/omarchy/default/hypr/envs.conf ~/.local/share/omarchy/default/hypr/envs.conf
cp local/share/omarchy/default/hypr/input.conf ~/.local/share/omarchy/default/hypr/input.conf
cp local/share/omarchy/default/hypr/looknfeel.conf ~/.local/share/omarchy/default/hypr/looknfeel.conf
cp local/share/omarchy/default/hypr/windows.conf ~/.local/share/omarchy/default/hypr/windows.conf

# Omarchy Shared Bindings
cp local/share/omarchy/default/hypr/bindings/clipboard.conf ~/.local/share/omarchy/default/hypr/bindings/clipboard.conf
cp local/share/omarchy/default/hypr/bindings/media.conf ~/.local/share/omarchy/default/hypr/bindings/media.conf
cp local/share/omarchy/default/hypr/bindings/tiling.conf ~/.local/share/omarchy/default/hypr/bindings/tiling.conf
cp local/share/omarchy/default/hypr/bindings/tiling-v2.conf ~/.local/share/omarchy/default/hypr/bindings/tiling-v2.conf
cp local/share/omarchy/default/hypr/bindings/utilities.conf ~/.local/share/omarchy/default/hypr/bindings/utilities.conf

# Omarchy Binaries
cp local/share/omarchy/bin/omarchy-menu ~/.local/share/omarchy/bin/omarchy-menu
cp local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle ~/.local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle
cp local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle ~/.local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle
chmod +x ~/.local/share/omarchy/bin/omarchy-menu
chmod +x ~/.local/share/omarchy/bin/omarchy-hyprland-workspace-layout-toggle
chmod +x ~/.local/share/omarchy/bin/omarchy-hyprland-window-single-square-aspect-toggle

# TMUX
cp config/tmux/tmux.conf ~/.config/tmux/tmux.conf

# XCompose
cp XCompose ~/.XCompose
cp local/share/omarchy/default/xcompose ~/.local/share/omarchy/default/xcompose

# Zed
cp -r local/share/zed/extensions/ ~/.local/share/zed/

echo "Done! All files moved."


#!/bin/bash

# Create directories that don't exist
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/hypr/icons
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/.config/swaync
mkdir -p ~/.config/waypaper
mkdir -p ~/.config/yazi
mkdir -p ~/.config/zed
mkdir -p ~/.local/bin

# --- Font Config ---
mv config/fontconfig/font.conf ~/.config/fontconfig/font.conf

# --- Fastfetch ---
mv config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

# --- Fish ---
mv config/fish/config.fish ~/.config/fish/config.fish
mv config/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish

# --- Ghostty ---
mv config/ghostty/config ~/.config/ghostty/config

# --- Hyprland ---
mv config/hypr/autostart.conf ~/.config/hypr/autostart.conf
mv config/hypr/bindings.conf ~/.config/hypr/bindings.conf
mv config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf
mv config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
mv config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
mv config/hypr/hyprsunset.conf ~/.config/hypr/hyprsunset.conf
mv config/hypr/input.conf ~/.config/hypr/input.conf
mv config/hypr/looknfeel.conf ~/.config/hypr/looknfeel.conf
mv config/hypr/mocha.conf ~/.config/hypr/mocha.conf
mv config/hypr/monitors.conf ~/.config/hypr/monitors.conf
mv config/hypr/xdph.conf ~/.config/hypr/xdph.conf
mv config/hypr/scripts/osd.sh ~/.config/hypr/scripts/osd.sh
mv config/hypr/scripts/osd.sh ~/.config/hypr/scripts/layout.sh
chmod +x ~/.config/hypr/scripts/osd.sh
chmod +x ~/.config/hypr/scripts/layout.sh

# Hyprland Icons
mv config/hypr/icons/brightness-down.svg ~/.config/hypr/icons/brightness-down.svg
mv config/hypr/icons/brightness-up.svg ~/.config/hypr/icons/brightness-up.svg
mv config/hypr/icons/mic-muted.svg ~/.config/hypr/icons/mic-muted.svg
mv config/hypr/icons/mic.svg ~/.config/hypr/icons/mic.svg
mv config/hypr/icons/volume-down.svg ~/.config/hypr/icons/volume-down.svg
mv config/hypr/icons/volume-muted.svg ~/.config/hypr/icons/volume-muted.svg
mv config/hypr/icons/volume-unmute.svg ~/.config/hypr/icons/volume-unmute.svg
mv config/hypr/icons/volume-up.svg ~/.config/hypr/icons/volume-up.svg
mv config/hypr/icons/eye.svg ~/.config/hypr/icons/eye.svg
mv config/hypr/icons/eye-off.svg ~/.config/hypr/icons/eye-off.svg
mv config/hypr/icons/lock.svg ~/.config/hypr/icons/lock.svg
mv config/hypr/icons/screensaver.svg ~/.config/hypr/icons/screensaver.svg
mv config/hypr/icons/battery.svg ~/.config/hypr/icons/bettery.svg
mv config/hypr/icons/clock.svg ~/.config/hypr/icons/clock.svg
mv config/hypr/icons/desktop.svg ~/.config/hypr/icons/desktop.svg

# --- Neovim ---
mv config/nvim/lua/config/keymaps.lua ~/.config/nvim/lua/config/keymaps.lua
mv config/nvim/lua/config/options.lua ~/.config/nvim/lua/config/options.lua

# --- Omarchy Branding ---
mv -r config/omarchy/branding ~/.config/omarchy/

# --- Omarchy Branding ---
mv config/omarchy/branding/about.txt ~/.config/omarchy/branding/about.txt
mv config/omarchy/branding/arch_mini.txt ~/.config/omarchy/branding/arch_mini.txt
mv config/omarchy/branding/arch.txt ~/.config/omarchy/branding/arch.txt
mv config/omarchy/branding/esh.txt ~/.config/omarchy/branding/esh.txt
mv config/omarchy/branding/omarchy.txt ~/.config/omarchy/branding/omarchy.txt
mv config/omarchy/branding/screensaver_og.txt ~/.config/omarchy/branding/screensaver_og.txt
mv config/omarchy/branding/screensaver.txt ~/.config/omarchy/branding/screensaver.txt

# --- Notifications & OSD ---
mv config/swaync/config.json ~/.config/swaync/config.json
mv config/swaync/style.css ~/.config/swaync/style.css
mv config/swayosd/config.toml ~/.config/swayosd/config.toml
mv config/swayosd/style.css ~/.config/swayosd/style.css

# --- Walker & Waybar ---
mv config/walker/config.toml ~/.config/walker/config.toml
mv config/waybar/config.jsonc ~/.config/waybar/config.jsonc
mv config/waybar/style.css ~/.config/waybar/style.css

# --- Waypaper ---
mv config/walpaper/config.ini ~/.config/waypaper/config.ini

# --- Yazi & Zed ---
mv config/yazi/theme.toml ~/.config/yazi/theme.toml
mv config/zed/keymap.json ~/.config/zed/keymap.json
mv config/zed/settings.json ~/.config/zed/settings.json

# --- Local Binaries ---
mv local/bin/area-screenshot ~/.local/bin/area-screenshot
mv local/bin/screenshot ~/.local/bin/screenshot
chmod +x ~/.local/bin/area-screenshot
chmod +x ~/.local/bin/screenshot

# Omarchy Shared Core Files
mv local/share/omarchy/default/hypr/apps.conf ~/.local/share/omarchy/default/hypr/apps.conf
mv local/share/omarchy/default/hypr/autostart.conf ~/.local/share/omarchy/default/hypr/autostart.conf
mv local/share/omarchy/default/hypr/bindings.conf ~/.local/share/omarchy/default/hypr/bindings.conf
mv local/share/omarchy/default/hypr/envs.conf ~/.local/share/omarchy/default/hypr/envs.conf
mv local/share/omarchy/default/hypr/input.conf ~/.local/share/omarchy/default/hypr/input.conf
mv local/share/omarchy/default/hypr/looknfeel.conf ~/.local/share/omarchy/default/hypr/looknfeel.conf
mv local/share/omarchy/default/hypr/windows.conf ~/.local/share/omarchy/default/hypr/windows.conf

# Omarchy Shared Bindings
mv local/share/omarchy/default/hypr/bindings/clipboard.conf ~/.local/share/omarchy/default/hypr/bindings/clipboard.conf
mv local/share/omarchy/default/hypr/bindings/media.conf ~/.local/share/omarchy/default/hypr/bindings/media.conf
mv local/share/omarchy/default/hypr/bindings/tiling.conf ~/.local/share/omarchy/default/hypr/bindings/tiling.conf
mv local/share/omarchy/default/hypr/bindings/tiling-v2.conf ~/.local/share/omarchy/default/hypr/bindings/tiling-v2.conf
mv local/share/omarchy/default/hypr/bindings/utilities.conf ~/.local/share/omarchy/default/hypr/bindings/utilities.conf

# TMUX
mv tmux.conf ~/.tmux.conf

# XCompose
mv XCompose ~/.XCompose
mv local/share/omarchy/default/xcompose ~/.local/share/omarchy/default/xcompose

# Code Editor Extensions
mv -r vscode/ ~/.vscode/
mv -r local/share/zed/extensions/ ~/.local/share/zed/

echo "Done! All files moved."


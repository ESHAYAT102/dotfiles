#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

shopt -s nullglob

# The repository defines the sync scope. Every existing top-level entry in
# config/ is mirrored from the matching live entry in ~/.config/. This copies
# everything below that entry and removes repository files that no longer
# exist in the live configuration.
for destination in "$SCRIPT_DIR"/config/*; do
  name="${destination##*/}"
  source="$HOME/.config/$name"

  if [[ -d $source && -d $destination ]]; then
    rsync -a --delete "$source/" "$destination/"
  elif [[ -e $source || -L $source ]]; then
    rsync -a "$source" "$destination"
  else
    printf 'Skipping %s: no live config at %s\n' "$name" "$source" >&2
  fi
done

# Zsh keeps its primary configuration directly in $HOME rather than
# ~/.config/zsh, so copy it after mirroring the zsh config directory.
if [[ -d "$SCRIPT_DIR/config/zsh" && -f "$HOME/.zshrc" ]]; then
  install -Dm644 "$HOME/.zshrc" "$SCRIPT_DIR/config/zsh/.zshrc"
fi
install -Dm644 "$HOME/.XCompose" "$SCRIPT_DIR/XCompose"

for relative in \
  local/bin/area-screenshot \
  local/bin/hyprland-load-plugins \
  local/bin/screenshot \
  local/bin/xdph-no-picker \
  local/share/omarchy/bin/omarchy-powerprofiles-set; do
  [[ -f "$HOME/.$relative" ]] || continue
  install -Dm755 "$HOME/.$relative" "$SCRIPT_DIR/$relative"
done

for relative in local/share/vicinae/shortcuts local/share/vicinae/extensions local/share/zed/extensions; do
  [[ -d "$HOME/.$relative" ]] || continue
  mkdir -p "$SCRIPT_DIR/$relative"
  rsync -a --delete "$HOME/.$relative/" "$SCRIPT_DIR/$relative/"
done

echo "Synced the live desktop profile into $SCRIPT_DIR"

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

config_dirs=(
  fastfetch fish ghostty hypr nvim omarchy swaync swayosd systemd tmux
  tmux-palette uwsm vicinae vscode waybar yazi zed
)

exclude_args=(
  --exclude='.git/'
  --exclude='node_modules/'
  --exclude='*.bak'
  --exclude='*.bak-*'
  --exclude='*.bak.*'
  --exclude='*.disabled'
  --exclude='*.log'
  --exclude='*.sock'
  --exclude='*history*'
  --exclude='session.json'
  --exclude='.plugins.lock'
  --exclude='fish_variables'
  --exclude='current'
  --exclude='current.pre-*'
  --exclude='private.fish'
  --exclude='private.zsh'
  --exclude='*.target.wants/'
)

for name in "${config_dirs[@]}"; do
  source_dir="$HOME/.config/$name"
  [[ -d $source_dir ]] || continue
  mkdir -p "$SCRIPT_DIR/config/$name"
  rsync -a "${exclude_args[@]}" "$source_dir/" "$SCRIPT_DIR/config/$name/"
done

if [[ -f "$SCRIPT_DIR/config/fish/config.fish" ]]; then
  sed -i '/_authToken=/d; /RESEND_API_KEY/d' "$SCRIPT_DIR/config/fish/config.fish"
fi

install -Dm644 "$HOME/.zshrc" "$SCRIPT_DIR/config/zsh/.zshrc"
# Never copy shell-embedded credentials into Git. Keep those in the local,
# untracked ~/.config/zsh/private.zsh file instead.
sed -i '/^export RESEND_API_KEY=/d; /_authToken=/d' "$SCRIPT_DIR/config/zsh/.zshrc"
grep -qF 'source "$HOME/.config/zsh/private.zsh"' "$SCRIPT_DIR/config/zsh/.zshrc" ||
  printf '\n[[ -r "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"\n' >> "$SCRIPT_DIR/config/zsh/.zshrc"
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
  rsync -a "${exclude_args[@]}" "$HOME/.$relative/" "$SCRIPT_DIR/$relative/"
done

echo "Synced the live desktop profile into $SCRIPT_DIR"

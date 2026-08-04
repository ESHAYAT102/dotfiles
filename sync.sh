#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sync_file() {
  local source=$1 destination=$2

  if [[ -e $source || -L $source ]]; then
    mkdir -p "$(dirname "$destination")"
    rsync -a "$source" "$destination"
  else
    printf 'Skipping %s: no live file at %s\n' \
      "${destination#"$SCRIPT_DIR"/}" "$source" >&2
  fi
}

# Update every file represented by the repository's config tree. Zsh has two
# live locations that differ from the repository layout.
while IFS= read -r -d '' destination; do
  relative=${destination#"$SCRIPT_DIR/config/"}
  case $relative in
    XCompose)
      source="$HOME/.XCompose"
      ;;
    zsh/.zshrc)
      source="$HOME/.zshrc"
      ;;
    zsh/catppuccin-mocha.zsh-theme)
      source="$HOME/.oh-my-zsh/custom/themes/catppuccin-mocha.zsh-theme"
      ;;
    *)
      source="$HOME/.config/$relative"
      ;;
  esac
  sync_file "$source" "$destination"
done < <(find "$SCRIPT_DIR/config" \( -type f -o -type l \) -print0)

# The repository's local/ tree maps directly to ~/.local/.
while IFS= read -r -d '' destination; do
  relative=${destination#"$SCRIPT_DIR/local/"}
  sync_file "$HOME/.local/$relative" "$destination"
done < <(find "$SCRIPT_DIR/local" \( -type f -o -type l \) -print0)

# Repository bin/ entries are the Omarchy command overrides installed in
# ~/.local/bin/.
while IFS= read -r -d '' destination; do
  relative=${destination#"$SCRIPT_DIR/bin/"}
  sync_file "$HOME/.local/bin/$relative" "$destination"
done < <(find "$SCRIPT_DIR/bin" \( -type f -o -type l \) -print0)

echo "Synced the live desktop profile into $SCRIPT_DIR"

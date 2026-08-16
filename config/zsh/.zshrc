export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="catppuccin-mocha"

plugins=(
  git
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source "$ZSH/oh-my-zsh.sh"

# Delete whole words with Ctrl+Backspace and Ctrl+Delete. The extra CSI-u
# bindings cover terminals that use the modern keyboard protocol.
bindkey '^H' backward-kill-word
bindkey '^[[127;5u' backward-kill-word
bindkey '^[[8;5u' backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[[57349;5u' kill-word

# Keep machine-specific credentials out of the dotfiles repository.
[[ -r "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"

typeset -U path PATH
export GOPATH="$HOME/.local/share/go"
export BUN_INSTALL="$HOME/.bun"
path=(
  "$HOME/.spicetify"
  "$HOME/.local/bin"
  "$GOPATH/bin"
  "$BUN_INSTALL/bin"
  $path
)

export BAT_THEME="Catppuccin Mocha"
export POP_FROM="hello@eshayat.com"

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  eval "$(zoxide init zsh --cmd cd)"
fi

[[ -r "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"
alias ss='ssh -p 23231 eshayat@homelab'
alias s='mosh --ssh="ssh -F /dev/null -i $HOME/.ssh/id_ed25519_homelab -o IdentitiesOnly=yes -o UserKnownHostsFile=$HOME/.ssh/known_hosts" eshayat@homelab'
alias w='ssh -i $HOME/.ssh/id_ed25519_windows -o IdentitiesOnly=yes "Md Anisur Rahman@windows"'
alias q='exit'
alias n='nvim'
alias h='herdr'
alias x='codex'
alias oc='opencode'
alias ocl='openclaude'
alias cr='crush'
alias u='sudo env OMARCHY_ALLOW_DIRECT_PACMAN=1 pacman -Syu -y --noconfirm && yay -Syu --noconfirm -y && bun upgrade && flatpak update -y'
alias ff='fastfetch'
alias t='tmux'
alias c='clear'
alias fk='thefuck'
alias zshconfig='nvim ~/.zshrc'
alias fishconfig='nvim ~/.config/fish/config.fish'
alias hyprconfig='nvim ~/.config/hypr/'
alias minecraft='java -jar "$HOME/Documents/minecraft.jar"'
alias mc='java -jar "$HOME/Documents/minecraft.jar"'
alias python='python3'
alias clock='tty-clock -c -b -s -t -C 7'
alias init='git init'
alias add='git add'
alias branch='git branch -M main'

hyprmod() {
  local target_dir="$HOME/.config/hyprmod"

  if [[ ! -d "$target_dir" ]]; then
    git clone https://github.com/BlueManCZ/hyprmod.git "$target_dir" || return
    builtin cd "$target_dir" || return
    uv sync || return
  fi

  builtin cd "$target_dir" || return
  uv run hyprmod
}

unalias ls 2>/dev/null
ls() {
  eza -l --git --icons --no-user --no-time --no-filesize "$@"
}

unalias l 2>/dev/null
l() {
  eza -l --git --icons --no-user --no-time --no-filesize "$@"
}

commit() {
  git commit -m "$*"
}

push() {
  if (( $# )); then
    git add . &&
      git commit -m "$*" &&
      git push --force
  else
    git push -u origin main
  fi
}

y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
  yazi "$@" --cwd-file="$tmp"
  cwd="$(command cat -- "$tmp")"
  if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  command rm -f -- "$tmp"
}

export PATH=$PATH:/home/esh/.spicetify

# try - ephemeral workspace manager
eval "$(try init ~/src/tries)"


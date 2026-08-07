[[ -r "$HOME/.zshrc" ]] && source "$HOME/.zshrc"

typeset -g _caelestia_prefill_pending=1

_caelestia_prefill_line() {
  if (( _caelestia_prefill_pending )); then
    BUFFER="${CAELESTIA_PREFILL:-}"
    CURSOR=${#BUFFER}
    _caelestia_prefill_pending=0
  fi
}

zle -N zle-line-init _caelestia_prefill_line

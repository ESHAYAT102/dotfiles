autoload -Uz colors && colors
setopt prompt_subst

ZSH_THEME_GIT_PROMPT_PREFIX="%F{#89b4fa}git:(%F{#cba6f7}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{#89b4fa})%f "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{#f38ba8} ✗%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{#a6e3a1} ✓%f"

PROMPT='%F{#cba6f7}%n%f %F{#89b4fa}%~%f $(git_prompt_info)%F{#a6e3a1}❯%f '

# Catppuccin Mocha colors for zsh-syntax-highlighting.
ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[function]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[path]='fg=#f9e2af,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#89dceb'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'


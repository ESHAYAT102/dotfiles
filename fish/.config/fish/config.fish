zoxide init fish | source
zoxide init fish --cmd cd | source

set -gx PATH $PATH /home/eshayat/.spicetify

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

set -gx PATH $HOME/.local/bin $PATH

alias edit msedit

alias q exit

alias update "sudo pacman -Syu && yay -Syu"

alias ff fastfetch

alias cls "clear && fastfetch"

alias fishconfig "nvim ~/.config/fish/config.fish"

alias minecraft "java -jar /home/eshayat/Documents/minecraft.jar"

alias mc "java -jar /home/eshayat/Documents/minecraft.jar"

alias python python3

alias ls "eza -l --git --icons --header"

function ls
    eza -l --git --icons --header $argv
end

alias init 'git init'
alias add 'git add .'
alias branch 'git branch -M main'
alias push 'git push -u origin main'

function commit
    git commit -m "$argv"
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

string match -q "$TERM_PROGRAM" kiro and . (kiro --locate-shell-integration-path fish)

ff

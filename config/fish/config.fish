zoxide init fish | source
zoxide init fish --cmd cd | source

set -gx PATH $PATH /home/eshayat/.spicetify

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

set -gx PATH $HOME/.local/bin $PATH

alias q exit

alias ai claude

alias update "sudo pacman -Syu && yay -Syu"

alias ff fastfetch

alias t tmux

alias c clear

alias fishconfig "nvim ~/.config/fish/config.fish"

alias hyprconfig "nvim ~/.config/hypr/"

alias minecraft "java -jar /home/eshayat/Documents/minecraft.jar"

alias mc "java -jar /home/eshayat/Documents/minecraft.jar"

alias python python3

alias clock "tty-clock -c -b -u -s -t -C 7"

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

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

export BAT_THEME="Catppuccin Mocha"

alias fk thefuck

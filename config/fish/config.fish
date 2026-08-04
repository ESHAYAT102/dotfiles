set -g fish_greeting ""

zoxide init fish | source
zoxide init fish --cmd cd | source

fish_add_path $HOME/.spicetify

fish_add_path $HOME/.local/bin

set -gx GOPATH $HOME/.local/share/go
fish_add_path $GOPATH/bin


set -x POP_FROM hello@eshayat.com

alias ss "ssh -p 23231 eshayat@homelab"

alias s "mosh --ssh='ssh -F /dev/null -i /home/esh/.ssh/id_ed25519_homelab -o IdentitiesOnly=yes -o UserKnownHostsFile=/home/esh/.ssh/known_hosts' eshayat@homelab"

alias w 'ssh "Md Anisur Rahman@windows"'

alias q exit

alias n nvim

alias x codex

alias oc opencode

alias ocl openclaude

alias cr crush

alias u "sudo env OMARCHY_ALLOW_DIRECT_PACMAN=1 pacman -Syu -y --noconfirm && yay -Syu --noconfirm -y && bun upgrade && flatpak update -y"

alias ff fastfetch

alias t tmux

alias c clear

alias fk thefuck

alias fishconfig "nvim ~/.config/fish/config.fish"

alias zshconfig "nvim ~/.zshrc"

alias hyprconfig "nvim ~/.config/hypr/"

alias minecraft "java -jar /home/esh/Documents/minecraft.jar"

alias mc "java -jar /home/esh/Documents/minecraft.jar"

alias python python3

alias clock "tty-clock -c -b -s -t -C 7"

function hyprmod
    set TARGET_DIR "$HOME/.config/hyprmod"

    if not test -d "$TARGET_DIR"
        echo "🚀 Directory not found. Cloning hyprmod..."
        git clone https://github.com/BlueManCZ/hyprmod.git "$TARGET_DIR"

        echo "📦 Syncing dependencies..."
        begin
            builtin cd "$TARGET_DIR"
            uv sync
        end
    end

    builtin cd "$TARGET_DIR"; and uv run hyprmod
end

function ls
    eza -l --git --icons --header --no-user --no-time $argv
end

alias init 'git init'
alias add 'git add .'
alias branch 'git branch -M main'
alias push 'git push -u origin main'

function commit
    git commit -m "$argv"
end

function push
    git add .
    git commit -m "$argv"
    git push --force
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

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

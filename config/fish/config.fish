set -g fish_greeting ""

zoxide init fish | source
zoxide init fish --cmd cd | source

set -gx PATH $PATH /home/eshayat/.spicetify

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

set -gx PATH $HOME/.local/bin $PATH

alias q exit

alias n nvim

alias ai codex

alias oc opencode

alias update "sudo pacman -Syu -y && yay -Syu --noconfirm -y && bun upgrade && flatpak update -y"

alias ff fastfetch

alias t tmux

alias c clear

alias fk thefuck

alias fishconfig "nvim ~/.config/fish/config.fish"

alias hyprconfig "nvim ~/.config/hypr/"

alias minecraft "java -jar /home/eshayat/Documents/minecraft.jar"

alias mc "java -jar /home/eshayat/Documents/minecraft.jar"

alias python python3

alias note skate

alias notes "skate list"

alias clock "tty-clock -c -b -u -s -t -C 7"

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

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

function __tdl_ensure_tmux
    if not set -q TMUX
        echo "TMUX is not running."
        read -P "Press ENTER to open a new TMUX session or Ctrl+C to cancel: " confirm

        set -l cmd_name $argv[1]
        set -l cmd_args $argv[2..-1]

        tmux new-session "fish -c '$cmd_name $cmd_args; exec fish'"
        exit
    end
end

function tdl
    __tdl_ensure_tmux tdl $argv

    if test (count $argv) -lt 1
        echo "Usage: tdl <ai_cmd> [<second_ai_cmd>]"
        return 1
    end

    set -l current_dir $PWD
    set -l ai $argv[1]
    set -l ai2 $argv[2]
    set -l editor_pane $TMUX_PANE

    tmux rename-window -t "$editor_pane" (basename "$current_dir")
    tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
    set -l ai_pane (tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

    if test -n "$ai2"
        set -l ai2_pane (tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
        tmux send-keys -t "$ai2_pane" "$ai2" C-m
    end

    tmux send-keys -t "$ai_pane" "$ai" C-m
    set -l cmd (set -q EDITOR; and echo $EDITOR; or echo "nvim")
    tmux send-keys -t "$editor_pane" "$cmd ." C-m
    tmux select-pane -t "$editor_pane"
end

function tdlm
    __tdl_ensure_tmux tdlm $argv

    if test (count $argv) -lt 1
        echo "Usage: tdlm <ai_cmd> [<second_ai_cmd>]"
        return 1
    end

    set -l ai $argv[1]
    set -l ai2 $argv[2]
    set -l base_dir $PWD
    set -l first true

    set -l session_name (basename "$base_dir" | string replace -a '.' '-' | string replace -a ':' '-')
    tmux rename-session "$session_name"

    for dir in $base_dir/*/
        if test -d "$dir"
            set -l dirpath (string trim -c '/' "$dir")
            if test "$first" = true
                tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
                set first false
            else
                tmux new-window -c "$dirpath" -n (basename "$dirpath") "tdl $ai $ai2; exec fish"
            end
        end
    end
end

function tsl
    __tdl_ensure_tmux tsl $argv

    if test (count $argv) -lt 2
        echo "Usage: tsl <pane_count> <command>"
        return 1
    end

    set -l count $argv[1]
    set -l cmd $argv[2]
    set -l current_dir $PWD
    set -l panes $TMUX_PANE

    tmux rename-window -t "$TMUX_PANE" (basename "$current_dir")

    while test (count $panes) -lt $count
        set -l split_target $panes[-1]
        set -l new_pane (tmux split-window -h -t "$split_target" -c "$current_dir" -P -F '#{pane_id}')
        set -a panes $new_pane
        tmux select-layout -t $panes[1] tiled
    end

    for pane in $panes
        tmux send-keys -t "$pane" "$cmd" C-m
    end

    tmux select-pane -t $panes[1]
end

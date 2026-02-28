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

alias update "sudo pacman -Syu && yay -Syu && bun upgrade && flatpak update"

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

function tdl
    if test (count $argv) -lt 1
        echo "Usage: tdl <ai_cmd> [<second_ai_cmd>]"
        return 1
    end

    if not set -q TMUX
        echo "You must start tmux to use tdl."
        return 1
    end

    set -l current_dir $PWD
    set -l ai $argv[1]
    set -l ai2 $argv[2]

    # Use the current pane as the editor pane
    set -l editor_pane $TMUX_PANE

    # Name window after current directory
    tmux rename-window -t "$editor_pane" (basename "$current_dir")

    # Split bottom terminal: 15% height
    tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

    # Split AI pane: 30% width on the right
    set -l ai_pane (tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

    # If second AI provided, split the AI pane vertically
    if test -n "$ai2"
        set -l ai2_pane (tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
        tmux send-keys -t "$ai2_pane" "$ai2" C-m
    end

    # Launch AI and Editor
    tmux send-keys -t "$ai_pane" "$ai" C-m
    # Use $EDITOR or fallback to nvim
    set -l cmd (set -q EDITOR; and echo $EDITOR; or echo "nvim")
    tmux send-keys -t "$editor_pane" "$cmd ." C-m

    # Focus back on editor
    tmux select-pane -t "$editor_pane"
end

function tdlm
    if test (count $argv) -lt 1
        echo "Usage: tdlm <ai_cmd> [<second_ai_cmd>]"
        return 1
    end

    if not set -q TMUX
        echo "You must start tmux to use tdlm."
        return 1
    end

    set -l ai $argv[1]
    set -l ai2 $argv[2]
    set -l base_dir $PWD
    set -l first true

    # Clean session name (Fish 'string replace' is much cleaner than 'tr')
    set -l session_name (basename "$base_dir" | string replace -a '.' '-' | string replace -a ':' '-')
    tmux rename-session "$session_name"

    for dir in $base_dir/*/
        # Ensure it's a directory
        if test -d "$dir"
            set -l dirpath (string trim -c '/' "$dir")

            if test "$first" = true
                tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
                set first false
            else
                set -l pane_id (tmux new-window -c "$dirpath" -P -F '#{pane_id}')
                tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
            end
        end
    end
end

function tsl
    if test (count $argv) -lt 2
        echo "Usage: tsl <pane_count> <command>"
        return 1
    end

    if not set -q TMUX
        echo "You must start tmux to use tsl."
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

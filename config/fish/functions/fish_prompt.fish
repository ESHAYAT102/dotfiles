# name: Default
# author: Eshayat

function fish_prompt --description 'Write out the simple ➜ ~ prompt'
    set -l normal (set_color normal)

    # ➜ symbol in a color (e.g., blue)
    set -l arrow_color (set_color green)

    set -l pwd_color (set_color green)

    echo -n -s $arrow_color "➜" $normal " " $pwd_color (prompt_pwd) $normal " "
end


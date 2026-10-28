function fish_right_prompt
    set -l color_time 71717a
    set -l color_git ffd6d6

    set -l git_part ''
    if command -sq git
        set -l branch (git branch --show-current 2>/dev/null)
        if test -n "$branch"
            set git_part (set_color $color_git)" $branch "
        end
    end

    echo -n -s $git_part(set_color $color_time)(date +"%H:%M")
end
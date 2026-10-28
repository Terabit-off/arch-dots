function fish_prompt
    set -l last_status $status
    set -l color_path 7e7e7e
    set -l color_arrow 86efac
    set -l color_error f38ba8

    echo -n (set_color $color_path)(prompt_pwd)
    echo -n (set_color 71717a)' '


    echo ''
    if test $last_status -ne 0
        echo -n (set_color $color_error)"!$last_status "
    end
    echo -n (set_color $color_arrow)'» '
end
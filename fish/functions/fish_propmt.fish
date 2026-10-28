function fish_prompt
    set -l last_status $status
    set -l color_path a1a1aa
    set -l color_arrow 86efac
    set -l color_error f38ba8

    # Верхняя строка: путь
    echo -n (set_color $color_path)(prompt_pwd)
    echo -n (set_color 6b7280)' '

    # Нижняя строка: стрелка и код ошибки
    echo ''
    if test $last_status -ne 0
        echo -n (set_color $color_error)"✘ $last_status "
    end
    echo -n (set_color $color_arrow)'❯ '
end
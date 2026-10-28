if status is-interactive
    # --- Внешний вид ---
    set -g fish_key_bindings fish_default_key_bindings
    set -g fish_greeting

    # --- Цвета fish под kitty / quickshell ---
    set -g fish_color_normal ffffff
    set -g fish_color_command 86efac
    set -g fish_color_param a1a1aa
    set -g fish_color_keyword f38ba8
    set -g fish_color_quote f9e2af
    set -g fish_color_redirection 8ab4f8
    set -g fish_color_end 7e7e7e
    set -g fish_color_error f38ba8
    set -g fish_color_comment 71717a
    set -g fish_color_autosuggestion 71717a
    set -g fish_color_selection --background=3f3f46
    set -g fish_color_search_match --background=3f3f46
    set -g fish_color_operator 8ab4f8
    set -g fish_color_escape ffd6d6
    set -g fish_color_cwd 86efac
    set -g fish_color_cwd_root f38ba8
    set -g fish_color_user 86efac
    set -g fish_color_host 8ab4f8
    set -g fish_color_host_remote f9e2af
    set -g fish_color_cancel f38ba8
    set -g fish_pager_color_progress 86efac
    set -g fish_pager_color_prefix 86efac
    set -g fish_pager_color_completion ffffff
    set -g fish_pager_color_description 71717a
    set -g fish_pager_color_selected_background 3f3f46

    # --- Полезные алиасы ---
    alias ll='eza -la --icons=auto --group-directories-first 2>/dev/null; or ls -la'
    alias ls='eza --icons=auto --group-directories-first 2>/dev/null; or ls'
    alias lt='eza --tree --level=2 --icons=auto 2>/dev/null; or find . -maxdepth 2'
end
function fish_prompt

set_color cyan
echo ""
echo -n (prompt_pwd)

if command -q git
    set git_branch (git branch --show-current 2>/dev/null)
    if test -n "$git_branch"
        set_color yellow
        echo -n " (git:$git_branch)"
    end
end

echo ""

set_color green
echo -n "➜ "
set_color normal

end
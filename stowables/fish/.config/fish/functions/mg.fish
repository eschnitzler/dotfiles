function mg
    set selection (manage | grep -vE '^\[.*\]|^Type|^Available|^\s*$' | awk '{print $1}' | fzf --prompt="Select Command:")
    if test -n "$selection"
        manage "$selection"
    else
        echo "Selection cancelled"
    end
end

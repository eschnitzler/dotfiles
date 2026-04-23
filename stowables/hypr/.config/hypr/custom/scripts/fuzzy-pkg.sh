#!/usr/bin/env bash

AUR_HELPER="yay"
MODE="${1:-install}"

if [[ "$MODE" != "install" && "$MODE" != "remove" ]]; then
    echo "Usage: $0 [install|remove]"
    exit 1
fi

if [[ "$MODE" == "install" ]]; then
    # Prompt user for a search term
    read -rp "Search package: " QUERY
    if [[ -z "$QUERY" ]]; then
        echo "No search term provided."
        exit 1
    fi

    # Search packages in repos + AUR without forcing --aur or --repo
    PKG_LINE=$(yay -Ss "$QUERY" | \
        # Keep only non-empty lines that do NOT start with a space (ignore descriptions)
        awk 'NF && !/^ /{print $0}' | \
        sort -u | \
        fzf --ansi \
            --prompt="Install package: " \
            --layout=reverse \
            --height=80% \
            --preview="yay -Si {1}" \
            --preview-window=wrap:down:40%)

    if [[ -n "$PKG_LINE" ]]; then
        # Extract package name (remove repo prefix)
        PKG=$(echo "$PKG_LINE" | awk '{print $1}' | awk -F'/' '{print $2}')

        read -rp "Install '$PKG'? [Y/n] " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ || -z "$CONFIRM" ]]; then
            "$AUR_HELPER" -S "$PKG"
        else
            echo "Cancelled."
        fi
    else
        echo "No package selected."
    fi

else
    # Remove installed packages
    PKG=$(pacman -Qq | fzf \
        --prompt="Remove package: " \
        --layout=reverse \
        --height=80% \
        --preview="pacman -Qi {}" \
        --preview-window=wrap:down:40%)

    if [[ -n "$PKG" ]]; then
        read -rp "Remove '$PKG'? [Y/n] " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ || -z "$CONFIRM" ]]; then
            sudo pacman -Rns "$PKG"
        else
            echo "Cancelled."
        fi
    else
        echo "No package selected."
    fi
fi

read -n 1 -s -r -p "Press any key to close..."
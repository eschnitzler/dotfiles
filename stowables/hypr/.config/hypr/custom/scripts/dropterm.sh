#!/usr/bin/env bash

# Check if dropdown terminal exists
if ! hyprctl clients | grep -q "class: kitty-dropdown"; then
  # Spawn new dropdown terminal
  kitty --class kitty-dropdown --title "Dropdown Terminal" --detach --directory ~
  sleep 0.3
fi

# Toggle using Hyprland's built-in special workspace toggle
hyprctl dispatch togglespecialworkspace dropdown
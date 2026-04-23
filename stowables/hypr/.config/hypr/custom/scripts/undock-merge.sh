#!/usr/bin/env bash
# Merge external monitor workspaces back to laptop when undocking
# Moves windows from workspaces 11-30 to 1-10

# Get the laptop monitor name (first one that starts with eDP)
LAPTOP=$(hyprctl monitors -j | jq -r '.[].name' | grep -E '^eDP' | head -1)

if [[ -z "$LAPTOP" ]]; then
    echo "No laptop monitor found"
    exit 1
fi

# Get all windows
windows=$(hyprctl clients -j)

# Move windows from workspace 11-20 to 1-10 (left external -> laptop)
for ws in {11..20}; do
    target_ws=$((ws - 10))
    # Get window addresses in this workspace
    addrs=$(echo "$windows" | jq -r ".[] | select(.workspace.id == $ws) | .address")
    for addr in $addrs; do
        hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr"
    done
done

# Move windows from workspace 21-30 to 1-10 (right external -> laptop)
for ws in {21..30}; do
    target_ws=$((ws - 20))
    addrs=$(echo "$windows" | jq -r ".[] | select(.workspace.id == $ws) | .address")
    for addr in $addrs; do
        hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr"
    done
done

# Focus workspace 1 on laptop
hyprctl dispatch workspace 1

echo "Workspaces merged to laptop"
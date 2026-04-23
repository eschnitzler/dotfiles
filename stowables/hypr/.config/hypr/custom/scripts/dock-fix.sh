#!/usr/bin/env bash
# Fix corrupted workspaces when docking
# Moves windows from invalid workspace IDs (>30) to proper external monitor workspaces

sleep 1  # Wait for monitors to stabilize

# Get all windows with corrupted workspace IDs (outside normal range)
windows=$(hyprctl clients -j)

# Fix windows on DP-3 (should be 11-20)
corrupted_dp3=$(echo "$windows" | jq -r '.[] | select(.monitor == 1 and (.workspace.id < 11 or .workspace.id > 20) and .workspace.id > 0) | .address')
for addr in $corrupted_dp3; do
    hyprctl dispatch movetoworkspacesilent "11,address:$addr"
done

# Fix windows on DP-4 (should be 21-30)
corrupted_dp4=$(echo "$windows" | jq -r '.[] | select(.monitor == 2 and (.workspace.id < 21 or .workspace.id > 30) and .workspace.id > 0) | .address')
for addr in $corrupted_dp4; do
    hyprctl dispatch movetoworkspacesilent "21,address:$addr"
done

# Focus default workspaces on external monitors
hyprctl dispatch workspace 11
hyprctl dispatch workspace 21

echo "Docked workspaces fixed"
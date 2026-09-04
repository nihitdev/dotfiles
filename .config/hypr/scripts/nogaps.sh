#!/bin/bash

while true; do
    # Get information about the active workspace
    workspace_info=$(hyprctl activeworkspace)

    # Extract the number of windows from the workspace information
    window_count=$(echo "$workspace_info" | grep -oP 'windows:\s*\K\d+')

    if (( window_count <= 1 )); then
    hyprctl --batch "\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 0"
    else
    hyprctl --batch "\
        keyword general:gaps_in 5;\
        keyword general:gaps_out 10;\
        keyword general:border_size 2"
    fi

    # Wait 1 second before next check
    sleep 0.5
done

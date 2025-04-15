#!/bin/bash

# Get current keyboard layout
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# Define layout names (modify as needed)
case "$current_layout" in
    "us") layout_name="English (US)" ;;
    "ir") layout_name="Persian" ;;
    *) layout_name="$current_layout" ;;
esac

# Show notification
notify-send -i input-keyboard "Keyboard Layout" "Switched to: $layout_name"

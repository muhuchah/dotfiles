#!/bin/bash

# Get screen dimensions
SCREEN_WIDTH=$(xdpyinfo | grep dimensions | awk '{print $2}' | cut -d'x' -f1)
SCREEN_HEIGHT=$(xdpyinfo | grep dimensions | awk '{print $2}' | cut -d'x' -f2)

# Calculate window size (80% of screen width, 70% of screen height)
WINDOW_WIDTH=$((SCREEN_WIDTH * 80 / 100))
WINDOW_HEIGHT=$((SCREEN_HEIGHT * 70 / 100))

# Calculate position (centered)
X_POS=$((SCREEN_WIDTH * 10 / 100))
Y_POS=$((SCREEN_HEIGHT * 15 / 100))

# Launch alacritty with bat for syntax highlighting
alacritty --class "Cheatsheet" \
    --title "System Shortcuts Cheatsheet" \
    --command bat --style=numbers,grid,header --color=always --theme="Nord" ~/.config/cheatsheet.md &

# Wait for the window to appear
# sleep 0.5

# Get the window ID
WINDOW_ID=$(xdotool search --class "Cheatsheet" | head -n1)

# Set window size and position
xdotool windowmove $WINDOW_ID $X_POS $Y_POS
xdotool windowsize $WINDOW_ID $WINDOW_WIDTH $WINDOW_HEIGHT 
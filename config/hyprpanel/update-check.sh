#!/usr/bin/env bash

# Get pacman updates count
pacman_count=0
if command -v checkupdates &> /dev/null; then
    pacman_count=$(checkupdates 2>/dev/null | wc -l)
fi

# Get AUR updates count
aur_count=0
if command -v yay &> /dev/null; then
    aur_count=$(yay -Qua 2>/dev/null | wc -l)
fi

# Calculate total
total=$((pacman_count + aur_count))

# Output JSON format
echo "{\"pacman\": $pacman_count, \"aur\": $aur_count, \"total\": $total}"

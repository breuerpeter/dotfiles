#!/bin/bash

# Minimize all windows except wezterm (for use with transparent terminal backgrounds)
# Requires Window Calls GNOME extension: https://github.com/ickyicky/window-calls

# Get list of windows as JSON
WINDOWS=$(gdbus call --session --dest org.gnome.Shell \
    --object-path /org/gnome/Shell/Extensions/Windows \
    --method org.gnome.Shell.Extensions.Windows.List 2>/dev/null)

if [ -z "$WINDOWS" ]; then
    exit 1
fi

# Parse JSON and minimize non-wezterm windows
echo "$WINDOWS" | grep -oP '\{[^}]+\}' | while read -r window; do
    wm_class=$(echo "$window" | grep -oP '"wm_class":"[^"]*"' | cut -d'"' -f4)
    window_id=$(echo "$window" | grep -oP '"id":[0-9]+' | grep -oP '[0-9]+')

    if [ -n "$window_id" ] && [ -n "$wm_class" ]; then
        if [[ ! "${wm_class,,}" =~ wezterm ]]; then
            gdbus call --session --dest org.gnome.Shell \
                --object-path /org/gnome/Shell/Extensions/Windows \
                --method org.gnome.Shell.Extensions.Windows.Minimize "$window_id" >/dev/null 2>&1
        fi
    fi
done

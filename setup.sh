#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Wezterm
ln -sf "$DOTFILES_DIR/wezterm" ~/.config/wezterm

# Bash snippets
SOURCE_LINE="source $DOTFILES_DIR/bash/px4.sh"
if ! grep -qF "$SOURCE_LINE" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Dotfiles" >> ~/.bashrc
    echo "$SOURCE_LINE" >> ~/.bashrc
    echo "Added bash snippets to ~/.bashrc"
else
    echo "Bash snippets already in ~/.bashrc"
fi

# Window Calls GNOME extension (for window manipulation on Wayland)
EXTENSION_UUID="window-calls@domandoman.xyz"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

if [ ! -d "$EXTENSION_DIR" ]; then
    echo "Installing Window Calls extension..."
    mkdir -p "$EXTENSION_DIR"
    curl -sL "https://github.com/ickyicky/window-calls/archive/refs/heads/main.tar.gz" | \
        tar xz --strip-components=1 -C "$EXTENSION_DIR"
    echo "Installed Window Calls extension"
else
    echo "Window Calls extension already installed"
fi

gnome-extensions enable "$EXTENSION_UUID" 2>/dev/null || echo "Note: Log out and back in to enable Window Calls extension"

# Make minimize-others script executable
chmod +x "$DOTFILES_DIR/minimize-others.sh"

# GNOME keybinding: Minimize all windows except wezterm (Super+Shift+M)
KEYBINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/minimize-others/"
CURRENT_BINDINGS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

if [[ "$CURRENT_BINDINGS" != *"minimize-others"* ]]; then
    if [[ "$CURRENT_BINDINGS" == "@as []" ]]; then
        NEW_BINDINGS="['$KEYBINDING_PATH']"
    else
        NEW_BINDINGS="${CURRENT_BINDINGS%]*}, '$KEYBINDING_PATH']"
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_BINDINGS"
fi

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEYBINDING_PATH name "Minimize others"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEYBINDING_PATH command "/bin/bash $DOTFILES_DIR/minimize-others.sh"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEYBINDING_PATH binding "<Super><Shift>m"
echo "Set up minimize-others keybinding (Super+Shift+M)"

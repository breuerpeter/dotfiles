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

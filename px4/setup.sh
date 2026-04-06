#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PX4_DIR="${PX4_DIR:-$HOME/code/px4}"

# Symlink pyproject.toml and local gitignore
ln -sfn "$SCRIPT_DIR/pyproject.toml" "$PX4_DIR/pyproject.toml"
echo "Linked pyproject.toml"
ln -sfn "$SCRIPT_DIR/git-exclude" "$PX4_DIR/.git/info/exclude"
echo "Linked git-exclude"

# Source helpers from ~/.bashrc
SOURCE_LINE="source $SCRIPT_DIR/helpers.sh"
if grep -qF "$SOURCE_LINE" ~/.bashrc 2>/dev/null; then
    echo "Helpers already in ~/.bashrc"
else
    echo "" >> ~/.bashrc
    echo "$SOURCE_LINE" >> ~/.bashrc
    echo "Added helpers to ~/.bashrc"
fi

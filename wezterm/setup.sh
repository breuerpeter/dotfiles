#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.config/wezterm
ln -sf "$SCRIPT_DIR/wezterm.lua" ~/.config/wezterm/wezterm.lua
echo "Linked config"

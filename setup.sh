#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Wezterm
ln -sf "$DOTFILES_DIR/wezterm" ~/.config/wezterm

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

# Claude Code - personal config
# Remove all symlinks in ~/.claude that point into our personal dir, then re-create
CLAUDE_PERSONAL_SRC="$DOTFILES_DIR/claude-code/personal"
CLAUDE_HOME="$HOME/.claude"
mkdir -p "$CLAUDE_HOME"

for link in "$CLAUDE_HOME"/*; do
    [ -L "$link" ] && [[ "$(readlink "$link")" == "$CLAUDE_PERSONAL_SRC/"* ]] && rm "$link"
done

for file in "$CLAUDE_PERSONAL_SRC"/*; do
    [ -e "$file" ] || continue
    target="$CLAUDE_HOME/$(basename "$file")"
    ln -sf "$file" "$target"
    echo "Linked Claude Code personal config: $(basename "$file") -> $target"
done

# Claude Code - status line config in settings.json
CLAUDE_SETTINGS="$CLAUDE_HOME/settings.json"
[ -f "$CLAUDE_SETTINGS" ] || echo '{}' > "$CLAUDE_SETTINGS"
if ! jq -e '.statusLine' "$CLAUDE_SETTINGS" > /dev/null 2>&1; then
    jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.py"}' "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp" \
        && mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
    chmod +x "$CLAUDE_HOME/statusline.py"
    echo "Configured Claude Code status line"
else
    echo "Claude Code status line already configured"
fi

# Claude Code - project configs
# For each dir in claude-code/project/, find the matching project dir and symlink
CLAUDE_PROJECT_SRC="$DOTFILES_DIR/claude-code/project"
SEARCH_DIRS=("$HOME/code" "$HOME/documents")

for project_dir in "$CLAUDE_PROJECT_SRC"/*/; do
    [ -d "$project_dir" ] || continue
    project_name="$(basename "$project_dir")"

    # Find the project dir (could be a git repo, submodule, or plain directory)
    repo_path=""
    for search_dir in "${SEARCH_DIRS[@]}"; do
        [ -d "$search_dir" ] || continue
        repo_path="$(find "$search_dir" -maxdepth 6 -type d -name "$project_name" -not -path "$CLAUDE_PROJECT_SRC/*" -print -quit)"
        [ -n "$repo_path" ] && break
    done

    if [ -z "$repo_path" ]; then
        echo "Warning: no directory found for '$project_name' under ${SEARCH_DIRS[*]}, skipping"
        continue
    fi

    target="$repo_path/.claude"
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        mv "$target" "$target.backup"
        echo "Backed up existing $target to $target.backup"
    fi

    ln -sf "$project_dir" "$target"
    echo "Linked Claude Code project config: $project_name -> $target"
done

# Git hooks - rerun setup after commits, checkouts, and merges
HOOKS_DIR="$DOTFILES_DIR/.git/hooks"
for hook in post-commit post-checkout post-merge; do
    hook_file="$HOOKS_DIR/$hook"
    hook_cmd="$DOTFILES_DIR/setup.sh"
    if [ ! -f "$hook_file" ] || ! grep -qF "$hook_cmd" "$hook_file"; then
        echo -e "#!/bin/bash\n$hook_cmd" > "$hook_file"
        chmod +x "$hook_file"
        echo "Installed git $hook hook"
    fi
done

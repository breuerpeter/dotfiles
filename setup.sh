#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# SSH
ln -sf "$DOTFILES_DIR/ssh/config" ~/.ssh/config
echo "Linked SSH config"

# Wezterm
ln -sfn "$DOTFILES_DIR/wezterm" ~/.config/wezterm

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

# Symlink files recursively, creating subdirs as real directories
link_files() {
    local src="$1" dst="$2" label="$3"
    for entry in "$src"/*; do
        [ -e "$entry" ] || continue
        local name="$(basename "$entry")"
        if [ -f "$entry" ]; then
            [ "$name" = "project.path" ] && continue
            ln -sf "$entry" "$dst/$name"
            echo "Linked $label: ${dst##*/}/$name"
        elif [ -d "$entry" ]; then
            [ -L "$dst/$name" ] && rm "$dst/$name"
            mkdir -p "$dst/$name"
            link_files "$entry" "$dst/$name" "$label"
        fi
    done
}

# Claude Code - symlink config files into each project's .claude/ dir
CLAUDE_PROJECT_SRC="$DOTFILES_DIR/claude-code"

for project_dir in "$CLAUDE_PROJECT_SRC"/*/; do
    [ -d "$project_dir" ] || continue
    project_name="$(basename "$project_dir")"

    # Read project path from project.path file
    if [ ! -f "$project_dir/project.path" ]; then
        echo "Warning: no project.path for '$project_name', skipping"
        continue
    fi
    repo_path="$(eval echo "$(cat "$project_dir/project.path")")"
    if [ ! -d "$repo_path" ]; then
        echo "Warning: '$repo_path' does not exist for '$project_name', skipping"
        continue
    fi

    target="$repo_path/.claude"

    # If .claude is a symlink (old style), remove it and create a real directory
    if [ -L "$target" ]; then
        rm "$target"
    fi
    mkdir -p "$target"

    link_files "$project_dir" "$target" "Claude Code config ($project_name)"
done

# PX4 helpers - source from ~/.bashrc
SOURCE_LINE="source $DOTFILES_DIR/px4_helpers.sh"
if grep -qF "$SOURCE_LINE" ~/.bashrc 2>/dev/null; then
    echo "PX4 helpers already in ~/.bashrc"
else
    echo "" >> ~/.bashrc
    echo "$SOURCE_LINE" >> ~/.bashrc
    echo "Added PX4 helpers to ~/.bashrc"
fi

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

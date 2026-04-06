#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Symlink config files into each project's .claude/ dir
for project_dir in "$SCRIPT_DIR"/*/; do
    [ -d "$project_dir" ] || continue
    project_name="$(basename "$project_dir")"

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

    if [ -L "$target" ]; then
        rm "$target"
    fi
    mkdir -p "$target"

    link_files "$project_dir" "$target" "$project_name"
done

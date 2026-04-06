#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Run setup.sh in each subdirectory
for setup in "$DOTFILES_DIR"/*/setup.sh; do
    [ -f "$setup" ] || continue
    echo "--- $(basename "$(dirname "$setup")") ---"
    bash "$setup"
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

# User-level Claude Code instructions

## Settings files

All Claude Code configuration is managed in `~/code/dotfiles/claude-code/` and symlinked to their active locations.

When I ask why I was (or wasn't) prompted for a tool action, read the relevant settings files below and explain which rule caused the behavior.

- **User settings**: `~/code/dotfiles/claude-code/user/settings.json` -> `~/.claude/settings.json`
- **Project settings**: `~/code/dotfiles/claude-code/project/<name>/settings.local.json` -> `<project>/.claude/settings.local.json`

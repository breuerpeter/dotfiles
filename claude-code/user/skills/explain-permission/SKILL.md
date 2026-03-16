---
name: explain-permission
description: Explain why Claude Code did or didn't prompt for permission on a tool action, by reading the relevant settings files
---

The user wants to understand why they were (or weren't) prompted for permission on a tool action.

All Claude Code configuration is managed in `~/code/dotfiles/claude-code/` and symlinked to their active locations:

- **User settings**: `~/code/dotfiles/claude-code/user/settings.json` -> `~/.claude/settings.json`
- **Project settings**: `~/code/dotfiles/claude-code/project/<name>/settings.local.json` -> `<project>/.claude/settings.local.json`

Steps:
1. Read the user settings file at `~/code/dotfiles/claude-code/user/settings.json`
2. Determine the current project and read its project settings file if one exists
3. Identify which permission rule(s) caused the behavior the user is asking about
4. Explain clearly which rule matched and from which settings file

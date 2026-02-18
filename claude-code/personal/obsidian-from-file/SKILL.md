---
name: obsidian-from-file
description: Convert a LaTeX or markdown file into Zettelkasten Obsidian notes
disable-model-invocation: true
argument-hint: <file-path>
---

Migrate the given file (LaTeX or markdown) into Zettelkasten Obsidian notes. Note conventions are defined in the wiki directory's CLAUDE.md (`~/documents/wiki/.claude/CLAUDE.md`).

- Don't comment on what you do, just produce the files
- Preserve original structure — don't change aligned equations or reorder content
- Content must remain identical — don't modify equations or information
- New notes go in "~/documents/wiki/_ai/<dirname of cwd ie name of subject>" (create the subdir first)

$ARGUMENTS

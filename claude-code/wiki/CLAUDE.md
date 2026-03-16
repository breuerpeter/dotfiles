# Obsidian vault conventions

This is a Zettelkasten-style Obsidian vault. Each concept gets its own note.

## Note structure
1. One sentence summarizing the method/idea (no heading, just the sentence)
2. Content sections with descriptive titles (not a generic "Content" heading)
3. Symbols table (title: "Symbols") with columns "Symbol" and "Description" for any LaTeX symbols used

## Formatting rules
- Concise, exact language
- LaTeX must be MathJax compatible:
	- Inline math between single `$`, display math between double `$$`
	- Use `\boldsymbol` instead of `bm`
	- Use `\boxed{}` for boxed content
	- Use `\color{red}` for colored symbols
	- Use `\dots` instead of `\hdots`
- No extra blank lines after headers
- Sentence case for section headers and file names
- Don't add the title in the note body — the filename is the title in Obsidian
- Info must never be repeated across notes
- Only end a bullet point sentence with a full stop if another sentence follows in the same bullet
- Media (pdf/png/jpg) goes in "~/documents/wiki/_media" and is referenced from the note


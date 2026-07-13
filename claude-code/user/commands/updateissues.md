---
description: Triage new GitHub issues — retitle, clarify, tag, mark as seen
argument-hint: [optional scope, e.g. an issue number or "all" for closed too]
---

Triage the GitHub issues in THIS project that I haven't reviewed yet. The
`claudeseen` label is the "I have triaged this" marker: an issue **without**
the `claudeseen` label is new (I filed it, or it came in externally) and needs
your attention. (Separately, the `claude` label marks issues *you* opened — AI
provenance — and is **not** the triage marker.) Your job is to clean each one up
and then tag it `claudeseen` so it drops off the list next time.

## Setup (do this first)

1. Read this project's `CLAUDE.md` to find where its issues live and how it
   labels them (the issue tracker location, and the label scheme / axes —
   typically a `type`, a `priority`, and one or more `area` labels, plus any
   provenance convention). If `CLAUDE.md` says nothing about a GitHub issue
   tracker, STOP and tell me — don't guess a repo.
2. Use the `gh` CLI; it resolves the repo from `origin`, so `--repo` is
   optional. Confirm access with `gh issue list`.
3. Discover the actual available labels with `gh label list` — reuse existing
   ones. Ensure the fixed labels exist, creating any that are missing:
   - `gh label create claudeseen --description "Triaged by Claude" --color 8957e5`
     — the whole mechanism depends on this one.
   - `gh label create claude --description "Opened by Claude (AI-generated)" --color 8957e5`
   - the priority axis: `gh label create "priority: high" …`, `"priority: medium"`,
     `"priority: low"` (create if the project uses them and they don't exist).

## Find the work

List every issue that lacks the `claudeseen` label:

```
gh issue list --state open --limit 200 --json number,title,labels \
  | jq -r '.[] | select(any(.labels[].name; . == "claudeseen") | not) | "#\(.number) \(.title)"'
```

Default to **open** issues. If `$ARGUMENTS` names a specific issue number, do
just that one; if it says "all" (or "closed"), sweep `--state all` too.

## For each untagged issue

1. **Read it fully first**, including comments:
   `gh issue view <n> --comments`. I often add context or "not fully fixed yet"
   notes in the comments — honor the latest ones.
2. **Retitle** it to something clear and specific (what + where), if the
   current title is vague. Keep it concise.
3. **Rewrite the description** so anyone reading it later understands what the
   issue actually is: the problem/observed-vs-expected (for bugs) or the goal
   (for enhancements), why it matters, and any open questions. When the
   original is terse, ground it in the codebase first (grep/read the relevant
   files) so the rewrite is accurate and can carry `file:line` anchors — but
   keep the effort proportional to the issue.
4. **Preserve the original verbatim at the END** of the body, under a clear
   heading, so any misinterpretation in your rewrite can be caught and traced:

   ```
   ---
   ### Original report (verbatim)
   **Original title:** <the title as it was before you changed it>

   <the original body text, unmodified — or "(no body)" if it was empty>
   ```

   If the body already preserves its original text (some imported backlogs do),
   don't duplicate it. If an issue is already well-formed and clear, you don't
   need to rewrite it or add an "Original report" block — just apply labels and
   the tag.
5. **Set the type and labels.** Set the **type** via GitHub's native Issue Type
   field — `gh issue edit <n> --type Bug|Feature|Task|Experiment` (one per
   issue); if a type isn't configured in the org (Experiment often isn't — it's
   not a GitHub default), fall back to a `type: experiment` label and note it.
   Apply one **priority** label (`priority: high|medium|low`). Add any
   **area/descriptive** labels that aid filtering, plus whatever this project's
   `CLAUDE.md` defines, reusing existing labels. Do **not** add the `claude`
   label here — that marks issues *you* opened, not ones you triaged.
6. **Mark it `claudeseen`** last, once the title/description/type/labels are
   done. This is what removes it from the untagged list.

Do all of this in one `gh issue edit <n> --title … --body-file - --type … --add-label …`
per issue where practical (heredoc the body to keep markdown clean).

## Rules

- **Don't lose information.** The rewrite clarifies; the verbatim block
  guarantees nothing is silently dropped.
- **Don't change issue state** (open/closed) and **don't close anything** —
  this is triage, not resolution.
- **Don't fold unrelated issues together.** Each issue stays its own item.
- **Re-check before finishing**: re-run the untagged query; the count should be
  0 (for the scope you ran). If a new untagged issue appeared mid-run (I may
  have filed one), it's in scope — handle it too.
- End with a short summary: which issues you touched and the labels you set. No
  "want me to…" offers.

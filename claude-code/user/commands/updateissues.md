---
description: Triage new GitHub issues — retitle, clarify, tag, mark as seen
argument-hint: [optional scope, e.g. an issue number or "all" for closed too]
---

Triage the GitHub issues in THIS project that I haven't reviewed yet. The
`claudeseen` label is the "I have triaged this" marker: an issue **without**
the `claudeseen` label is new (I filed it, or it came in externally) and needs
your attention. Your job is to clean each one up and then tag it `claudeseen` so
it drops off the list next time.

**Assignee gate — pause on human-assigned issues.** Unassigned issues are yours
to triage freely — that's the normal case. But if an issue has a **human
assignee**, someone is already on it, so **don't edit it without asking me
first**: surface it, say who it's assigned to, and get my explicit approval
before you retitle/rewrite/label/tag it. Don't assign or unassign issues
yourself.

## Setup (do this first)

1. Read this project's `CLAUDE.md` to find where its issues live and how it
   labels them (the issue tracker location, and the label scheme — **type** and
   **priority** are native GitHub fields set by me at creation, not yours to
   touch; labels are for **area / descriptive** tags plus the provenance
   convention). If `CLAUDE.md` says
   nothing about a GitHub issue
   tracker, STOP and tell me — don't guess a repo.
2. Use the `gh` CLI; it resolves the repo from `origin`, so `--repo` is
   optional. Confirm access with `gh issue list`.
3. Discover the actual available labels with `gh label list` — reuse existing
   ones. Ensure the fixed labels exist, creating any that are missing:
   - `gh label create claudeseen --description "Triaged by Claude" --color 8957e5`
     — the whole mechanism depends on this one.
   - **Never create `priority: *` or `type: *` labels** — both are native issue
     fields, and I set them when I file the issue.

## Find the work

List every issue that lacks the `claudeseen` label, and surface its assignees so
you can apply the assignee gate:

```
gh issue list --state open --limit 200 --json number,title,labels,assignees \
  | jq -r '.[] | select(any(.labels[].name; . == "claudeseen") | not)
      | "#\(.number) \(.title)\t[assignees: \((.assignees | map(.login)) | join(",") // "none")]"'
```

Triage the unassigned ones directly. For any that has a human assignee, **stop
and ask me** before touching it (see the assignee gate above).

Default to **open** issues. If `$ARGUMENTS` names a specific issue number, do
just that one. If it says "all" (or "closed"), sweep `--state all` too.

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
5. **Set the labels — and only the labels.** Add **area/descriptive** labels that
   aid filtering, plus whatever this project's `CLAUDE.md` defines, reusing
   existing ones. Never record type or priority as a label: don't apply the
   default `bug` / `enhancement` (or `feature`/`task`/`type:`/`priority:`)
   labels.

   **Leave Type and Priority alone.** I set both when I file the issue. Read
   them for context; if one looks wrong, say so in your summary rather than
   changing it.
6. **Mark it `claudeseen`** last, once the title, description and labels are
   done. This is what removes it from the untagged list.

Do all of this in one `gh issue edit <n> --title … --body-file - --add-label …`
per issue where practical (heredoc the body to keep markdown clean).

## Rules

- **Human-assigned issues need my go-ahead.** Triage unassigned issues freely;
  if an issue has a human assignee, ask me before any edit (title, body, labels,
  or the `claudeseen` tag). Never add/remove assignees yourself.
- **Don't lose information.** The rewrite clarifies; the verbatim block
  guarantees nothing is silently dropped.
- **Don't change issue state** (open/closed) and **don't close anything** —
  this is triage, not resolution.
- **Don't fold unrelated issues together.** Each issue stays its own item.
- **Re-check before finishing**: re-run the untagged query. The only issues that
  should still lack `claudeseen` are ones with a human assignee that I haven't
  approved you to edit — those are expected to remain, not leftover work. If a
  new untagged unassigned issue appeared mid-run, it's in scope — handle it too.
- End with a short summary: which issues you touched and the labels you set, plus
  a note of any human-assigned issues you held back on pending my approval. No
  "want me to…" offers.

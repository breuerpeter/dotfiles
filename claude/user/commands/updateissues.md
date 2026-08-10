---
description: Triage new GitHub issues: retitle, clarify, tag, mark as seen
argument-hint: [optional scope, e.g. an issue number or "all" for closed too]
---

Triage the GitHub issues in THIS project that I haven't reviewed yet. The
`claudeseen` label is the "I have triaged this" marker: an issue **without** it is
new and needs your attention. Clean each one up, then tag it `claudeseen` so it
drops off the list next time.

**Load the `github-conventions` skill first.** It defines what a good title and a
good issue body look like, and this command does not repeat any of it. This file
covers only what is specific to a triage run.

Triage means titles, bodies and labels. No implementation, no state changes.

## Setup

1. Read this project's `CLAUDE.md` for where its issues live and any extra label
   axes it defines. If it names no GitHub issue tracker, STOP and tell me. Do not
   guess a repo.
2. Confirm access with `gh issue list`.
3. Discover the available labels with `gh label list` and reuse existing ones.
   Create `claudeseen` if it is missing. The whole mechanism depends on it:
   `gh label create claudeseen --description "Triaged by Claude" --color 8957e5`

## Find the work

```
gh issue list --state open --limit 200 --json number,title,labels,assignees \
  | jq -r '.[] | select(any(.labels[].name; . == "claudeseen") | not)
      | "#\(.number) \(.title)\t[assignees: \((.assignees | map(.login)) | join(",") // "none")]"'
```

Default to **open** issues. If `$ARGUMENTS` names an issue number, do just that
one. If it says "all" (or "closed"), sweep `--state all` too.

## Assignee gate

Unassigned issues are yours to triage freely. That is the normal case.

If an issue has a **human assignee**, someone is already working on it. Surface
it, say who it is assigned to, and get my explicit approval before you retitle,
rewrite, label or tag it. Never add or remove assignees yourself.

## For each issue

1. **Read it fully, including comments** (`gh issue view <n> --comments`). I add
   context and "not fully fixed yet" notes there; honour the latest ones.
2. **Retitle** it if the current title is vague, following the skill's title
   rules.
3. **Rewrite the body** to the structure the skill defines, grounded in the
   codebase with `file:line` anchors where they help. Keep the effort
   proportional to the issue. One that is already well-formed needs no rewrite.

   Fill the fields the issue was filed with, and leave the later sections alone:

   - **Design spec: never fill it here.** It is written after a design session,
     never from a guess, and triage is a fast pass over a backlog.
   - **Findings: usually leave empty.** Triage clarifies what was reported, it
     does not investigate. Record something only if you actually verified it
     while grounding the report, such as a referenced function having moved.
   - **Open decisions: fill it when you hit a real ambiguity.** If the report can
     be read two ways and the code does not settle it, that blocks the work and
     needs my call. Write the readings and their consequences.
4. **Apply area and component labels** that aid filtering.
5. **Mark it `claudeseen`** last, once title, body and labels are done.

Do each issue in one `gh issue edit <n> --title … --body-file … --add-label …`
where practical.

## Rules

- **Don't lose information.** The rewrite clarifies; it never drops a fact.
- **Don't change issue state**, and don't close anything.
- **Don't merge or split issues.** Both need my explicit instruction.
- **Re-run the query before you finish.** The only issues that should still lack
  `claudeseen` are human-assigned ones I haven't approved. A new unassigned issue
  that arrived mid-run is in scope, so handle it too.
- End with a short summary: which issues you touched, the labels you set, and any
  human-assigned ones you held back on. Note any Type or Priority that looks
  wrong rather than changing it.

## Structure notes

Close the summary with what you noticed about how the issues relate. Triage is
the only pass that sees the whole backlog at once. **Report all of it, change
none of it.**

- **Milestones.** Issues that belong to a milestone that already exists, and any
  cluster that looks like a milestone nobody has created yet. Milestones are mine
  alone, so a suggestion is the only way you can act on one.
- **Sub-issues.** Two issues where one is genuinely part of the other, or one
  issue that is really several independent pieces of work. Apply the test in
  `github-conventions`: a piece earns its own issue when it needs its own
  Findings or its own Open decisions.
- **Dependencies.** Any issue that cannot start until another one lands.
- **Duplicates.** Issues covering the same ground.

Suggest all four in chat. Never create the link, the milestone or the split.

Most issues at triage time have no Design spec yet, so the spec-level sub-issue
question rarely fires here. It belongs to whoever writes the spec.

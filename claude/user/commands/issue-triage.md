---
description: Triage new GitHub issues: retitle, clarify, tag, mark as seen
argument-hint: [optional scope, e.g. an issue number or "all" for closed too]
---

Triage the GitHub issues in THIS project that I haven't reviewed yet. The
`triaged` label is the "I have triaged this" marker: an issue **without** it is
new and needs your attention. Clean each one up, then tag it `triaged` so it
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
   Create `triaged` if it is missing. The whole mechanism depends on it:
   `gh label create triaged --description "Triaged: title and body are clear and accurate" --color 8957e5`

## Find the work

```
gh issue list --state open --limit 200 --json number,title,labels,assignees \
  | jq -r '.[] | select(any(.labels[].name; . == "triaged") | not)
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

   **React 👍 on each comment as you absorb it into the body**, exactly as the
   comment inbox does. The two paths must leave the same trace, or the comments
   on an issue you triage today come back as unprocessed work tomorrow, once the
   issue carries `triaged` and the inbox starts sweeping it. A comment that needs
   a human reply gets a draft in chat and no reaction.
2. **Settle the Type before touching the body**, because the body's shape comes
   from that type's form. If the Type is unset, decide the one you will propose
   and draft against it. If it is already set, use its form even if you would
   have chosen differently.
3. **Retitle** it if the current title is vague, following the skill's title
   rules.
4. **Rewrite the body** against `.github/ISSUE_TEMPLATE/<type>.yml`: its fields
   as `##` headings, in the order the form declares them, then the three later
   sections. Read the form, do not recall it. Ground the content in the codebase
   with `file:line` anchors where they help. Keep the effort proportional. One
   that is already well-formed needs no rewrite.

   An issue I filed as one sentence has no structure at all. Build it, move the
   sentence into the field it belongs in, and leave the rest empty.

   An issue that already has a body gets rewritten, never appended to, per the
   skill.

   Fill the form's own fields from what the report says. Leave the three later
   sections alone, with one exception:

   - **Design spec: never fill it here.** It is written after a design session,
     never from a guess, and triage is a fast pass over a backlog.
   - **Findings: usually leave empty.** Triage clarifies what was reported, it
     does not investigate. Record something only if you actually verified it
     while grounding the report, such as a referenced function having moved.
   - **Open decisions: fill it when you hit a real ambiguity.** If the report can
     be read two ways and the code does not settle it, that blocks the work and
     needs my call. Write the readings and their consequences.
5. **Apply area and component labels** that aid filtering.
6. **Mark it `triaged`** last, once title, body and labels are done.

Do each issue in one `gh issue edit <n> --title … --body-file … --add-label …`
where practical.

## Type and Priority

I usually file an issue as a sentence or two with neither set, so working both out is part of triage. **Proposing them is yours, deciding is mine.**

You settled the Type at step 2 in order to shape the body. Carry that proposal here rather than deciding twice, and work out the Priority alongside it.

- **Type**: `Bug` when something is broken, `Feature` for a new capability, `Task` for a chore, refactor or infrastructure work.
- **Priority**: `Urgent`, `High`, `Medium`, `Low`. Judge it on what it costs to leave alone, not on how interesting it is. Something that blocks other work, corrupts data or is user-visible outranks something that only annoys.

Never touch a Type or Priority that is already set. If one looks wrong, say so and leave it.

**Collect proposals across the whole run and put them in one table at the end**, so I answer once instead of per issue. **Every row carries the title, not just the number** — I do not remember which issue is which number (see the skill's "Naming issues in chat"):

```
  #    Title                                    Type      Priority   Why
  61   Push silently drops rows on failure      Bug       High       Data loss, no warning
  62   Retire the unused capture flag           Task      Low        Tidy-up; nothing depends on it
```

One line of reasoning each, no essays. Then set only what I approve. The skill has the commands, and note that Priority needs GraphQL and two ids, not a label.

## Comment inbox

The 👍 reaction marks a comment as absorbed (see the skill). Triage is the only
pass that sweeps the whole backlog, so it also owns the inbox: comments on
**open**, already-triaged issues that nobody absorbed yet.

Scope the sweep to open triaged issues first, then filter the comment feed
against it. Deriving the scope from `gh issue list` excludes closed issues and
pull requests structurally, so neither can leak in:

```
gh issue list --state open --limit 200 --json number,labels \
  --jq '[.[] | select(any(.labels[].name; . == "triaged")) | .number]' > /tmp/inbox-scope.json

gh api "repos/{owner}/{repo}/issues/comments" --paginate \
  | jq -r --slurpfile scope /tmp/inbox-scope.json '
      .[] | select(.reactions["+1"] == 0)
          | select((.issue_url | split("/") | last | tonumber) as $n | $scope[0] | index($n))
          | "\(.id)\t\(.html_url)\t\(.body[0:100])"'
```

- **Leave closed issues alone entirely.** Do not absorb into them, do not react
  on their comments, do not mention them. A closed issue is off the worklist, so
  there is no work for the 👍 to record. If a closed issue's body is wrong or its
  comments were never absorbed, say so in chat and change nothing.
- Comments on issues that lack `triaged` are the main pass's job, not the
  inbox's. It reads those in full at step 1.
- Comments on a PR are `/pr-todos` territory.
- For each of the rest: absorb anything substantive into the issue body, then
  react 👍 on the comment. A comment that needs a human reply gets a draft in
  chat instead, and no reaction until the point is settled.

Absorbing means rewriting the sections the comment touches, not adding a block
that records what the comment said. The comment arrives with a date attached, and
that date looks like structure, so this is where the skill's rewrite-never-append
rule is easiest to break.

## Organization pass

Triage is the only pass that sees the whole backlog at once, so it also owns two
invariants. Run this after the per-issue loop.

- **Every open issue sits on a milestone.** For each one that doesn't: if it
  fits a milestone that already exists, point that out in the summary — fit is
  a judgment call, so propose it rather than assign it. If it fits none, assign
  it to the **Backlog** milestone yourself (`gh issue edit <n> --milestone
  Backlog`). If no Backlog milestone exists, say so and stop there; creating
  milestones stays mine.
- **Every issue is atomic — no umbrella issues**, per the skill. Triage is the
  pass that spots them, because it is the only one that sees the whole backlog.
  Propose the split; never execute one without my explicit instruction.

## Rules

- **Don't lose information.** The rewrite clarifies; it never drops a fact.
- **Don't change issue state**, and don't close anything.
- **Don't touch closed issues at all**, in any part of the run, unless
  `$ARGUMENTS` explicitly says "all" or "closed". No body edits, no labels, no
  reactions. They are closed for a reason.
- **Don't merge or split issues.** Both need my explicit instruction.
- **Re-run the query before you finish.** The only issues that should still lack
  `triaged` are human-assigned ones I haven't approved. A new unassigned issue
  that arrived mid-run is in scope, so handle it too.
- End with a short summary: which issues you touched, the labels you set, and any
  human-assigned ones you held back on. Note any Type or Priority that looks
  wrong rather than changing it.

## Structure notes

Close the summary with what you noticed about how the issues relate. Beyond the
organization pass above (which acts), these are report-only:

- **Milestone clusters.** Any group of issues that looks like a milestone nobody
  has created yet. Creating one is mine alone, so a suggestion is the only way
  you can act on it.
- **Sub-issues.** Two issues where one is genuinely part of the other. Apply the
  test in `github-conventions`: a piece earns its own issue when it needs its
  own Findings or its own Open decisions.
- **Dependencies.** Any issue that cannot start until another one lands, where
  the `Blocked by` link is missing.
- **Duplicates.** Issues covering the same ground.

Suggest these in chat. Never create the milestone, the merge or the split.

Most issues at triage time have no Design spec yet, so the spec-level sub-issue
question rarely fires here. It belongs to whoever writes the spec.

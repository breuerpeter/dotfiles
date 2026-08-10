---
description: Build a specced issue and open its PR
argument-hint: the issue number, e.g. 37
---

Implement issue `$ARGUMENTS` from its Design spec, then open the PR.

Load the `github-conventions` skill first.

## Refuse to start unless the definition is done

Read the whole issue, including comments, then check these in order. Each one
stops the command.

1. **The issue is blocked by an open issue.** Check

   ```
   gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by \
     --jq '.[] | select(.state == "open") | .number'
   ```

   Any output stops the command: the seam this spec builds on does not exist
   yet.
2. **Open decisions is not empty.** Those are mine to settle. List them and stop.
3. **Design spec is empty.** Stop and suggest `/spec-issue`.
4. **Design spec does not meet the bar.** Name the missing part and stop. The bar
   is in `github-conventions`: an agent given only this issue can implement it
   without asking a question. In practice, check for the do-not-break list,
   scope, and acceptance commands. A spec with no acceptance criteria cannot tell
   you when you are done.

This gate is the point of the command. Time spent in definition is repaid many
times over in implementation, so a thin spec is worth stopping for, not working
around.

## Re-ground the spec first

The spec was verified against a main that has moved since. Before the first
commit, check every `file:line` anchor and every stated assumption against
current main. A moved line you fix silently by reading the code. Real drift —
a seam that changed shape, a test that moved, an assumption that no longer
holds — is "the spec turned out wrong": stop and follow that section. If the
spec names the commit it was verified against, diff against it to find what
moved.

## Build

1. Branch off the default branch.
2. **Follow the spec's stated order.** If it gives a commit table, use it, one
   commit per row. Order in a spec is usually load-bearing.
3. Respect the do-not-break list literally. If the spec says a test file stays
   unmodified, it stays unmodified.
4. Run the acceptance commands from the spec. Report the real output. A failing
   gate is a result, not something to work around.

## When the spec turns out wrong

Stop. Do not improvise around it.

Tell me what the spec says, what you found, and what you think it should say.
Once I agree, update the issue body so the spec matches reality, then carry on.
The issue stays the single source of truth, so a spec that no longer describes
the work is a bug in the issue.

## Finish

Open the PR, built from `.github/PULL_REQUEST_TEMPLATE.md`, with `Closes #<n>` in
the body so the issue links and closes on merge. If this PR delivers only part
of the issue, use `Refs #<n>` instead; `Closes` belongs to the finishing PR
alone, because the first merged `Closes` closes the issue.

Then hand me the external review command, ready to paste. I have to run it
myself; you cannot invoke it. The branch must still be checked out — it reviews
`HEAD` against the base.

```
/codex:adversarial-review --base <default branch> Review against issue #<n>: the do-not-break list and the `### Acceptance` commands in its Design spec.
```

When the review returns, I decide whether you post the confirmed findings as
line-anchored review comments on the PR, where `/pr-todos` picks them up.

Do not edit the issue body except to record a spec deviation I approved. Ask
before pushing.

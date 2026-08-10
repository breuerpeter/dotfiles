---
description: Build a specced issue and open its PR
argument-hint: the issue number, e.g. 37
---

Implement issue `$ARGUMENTS` from its Design spec, then open the PR.

Load the `github-conventions` skill first.

## Refuse to start unless the definition is done

Read the whole issue, including comments, then check these in order. Each one
stops the command.

1. **Open decisions is not empty.** Those are mine to settle. List them and stop.
2. **Design spec is empty.** Stop and suggest `/spec-issue`.
3. **Design spec does not meet the bar.** Name the missing part and stop. The bar
   is in `github-conventions`: an agent given only this issue can implement it
   without asking a question. In practice, check for the do-not-break list,
   scope, and acceptance commands. A spec with no acceptance criteria cannot tell
   you when you are done.

This gate is the point of the command. Time spent in definition is repaid many
times over in implementation, so a thin spec is worth stopping for, not working
around.

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
the body so the issue links and closes on merge.

Do not edit the issue body except to record a spec deviation I approved. Ask
before pushing.

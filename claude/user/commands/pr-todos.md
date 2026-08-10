---
description: Work through the open TODOs on a GitHub PR, one commit each
argument-hint: the PR number, e.g. 42
---

Work through the open action items on PR `$ARGUMENTS`, one commit at a time.

Load the `github-conventions` skill first. It holds the two PR comment surfaces
and how to reply on a review thread.

## Gather

Three sources. Derive `{owner}/{repo}` with `gh repo view --json nameWithOwner --jq .nameWithOwner`.

| Source | Command | What to look for |
|---|---|---|
| PR description | `gh pr view $ARGUMENTS --json body --jq .body` | unchecked `- [ ]` boxes |
| Review comments | `gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments --paginate` | each has `body`, `path`, `line`, `diff_hunk` |
| Conversation | `gh pr view $ARGUMENTS --json comments --jq .comments` | requests and suggestions, not praise |

Not every comment is a todo. "Nice work" is not an action item, "we should also handle the empty array" is.

## Present the list, then stop

Number every item. For each: what to do, where it applies (`file:line`, or "PR description", or "conversation"), and who asked.

Stop there. The user confirms the list or edits it. Do not start until they answer.

## Work each item

1. Make the change.
2. Say how to verify it: what to run, what to look at. Wait for the user to confirm it is good.
3. Commit it on its own. One item, one commit.
4. Ask before pushing.
5. Close the loop on the source:
   - a description checkbox becomes `- [x]` via `gh pr edit`
   - a review comment gets a reply on its own thread
   - a conversation item gets a top-level reply

   Keep the reply short: what changed, which files, and one line of rationale if the approach was not obvious.

If an item is ambiguous, ask rather than guess.

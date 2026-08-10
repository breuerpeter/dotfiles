---
description: Work through the open TODOs on a GitHub PR, one commit each
argument-hint: the PR number, e.g. 42
---

Work through the open action items on PR `$ARGUMENTS`, one commit at a time.

Load the `github-conventions` skill first. It holds the two PR comment surfaces
and the no-discussion-comments rule this command works under.

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
5. Close the loop on the source. Never write a comment; the 👍 reaction is the
   completion marker.
   - a description checkbox becomes `- [x]` via `gh pr edit`
   - a review comment gets a 👍 reaction, then its thread is resolved:

     ```
     gh api -X POST repos/{owner}/{repo}/pulls/comments/<id>/reactions -f content=+1
     ```

     Find the thread id by matching the comment's `databaseId` in
     `reviewThreads(first:100){ nodes{ id comments(first:1){ nodes{ databaseId }}}}`
     on the pull request, then
     `mutation{ resolveReviewThread(input:{threadId:"..."}){ thread{ isResolved }}}`.
   - a conversation item gets a 👍 reaction:

     ```
     gh api -X POST repos/{owner}/{repo}/issues/comments/<id>/reactions -f content=+1
     ```
   - if the item changed the approach, fold the rationale into the PR
     description; the commit carries the what, the description carries the why

An item you will not do gets no reaction: draft the reply in chat for the user
to post, and leave the thread open. If an item is ambiguous, ask rather than
guess.

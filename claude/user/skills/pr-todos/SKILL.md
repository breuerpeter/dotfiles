---
name: pr-todos
description: "Work through open TODOs from a GitHub PR thread. Takes a PR number as argument, extracts all action items (unresolved review comments, suggestions in general comments, unchecked checkboxes in the PR description), presents them for approval, then implements each one with a separate commit. Use this whenever the user wants to address PR feedback, resolve review comments, or work through PR todos."
user_invocable: true
---

# /pr-todos

Work through open TODOs from a GitHub pull request, one commit at a time.

## Input

`$ARGUMENTS` is the PR number (e.g., `42`).

## Step 1: Gather all action items from the PR

Use `gh` to pull everything from the PR thread. You need three sources:

**PR description checkboxes:**
```bash
gh pr view $ARGUMENTS --json body --jq '.body'
```
Look for unchecked checkboxes (`- [ ]`).

**Review comments (threaded comments on specific lines):**
```bash
gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments --paginate
```
Each review comment has `body`, `path`, `line`/`original_line`, and `diff_hunk` for context. These are often the most actionable — a reviewer pointing at a specific line saying "rename this" or "add a check here."

**General PR comments (top-level conversation):**
```bash
gh pr view $ARGUMENTS --json comments --jq '.comments'
```
Parse these for requests, suggestions, or action items. Not every comment is a todo — use judgment to distinguish "nice work!" from "we should also handle the empty array case."

Derive `{owner}/{repo}` from the git remote:
```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

## Step 2: Present the todo list

Show a numbered list of all extracted action items. For each, include:
- A short summary of what needs to be done
- Where it applies (file + line if from a review comment, or "PR description" / "PR comment")
- Who requested it

Example format:
```
Found 4 TODOs from PR #42:

1. Rename `processData` to `parseFlightLog` — src/parser.ts:145 (reviewer: alice)
2. Add null check before accessing `msg.fields` — src/parser.ts:203 (reviewer: alice)
3. Update the README with new CLI flags — PR comment (reviewer: bob)
4. Add unit test for empty log file — PR description checkbox
```

Then ask: **"Want me to work through all of these, or would you like to edit the list first?"**

Wait for the user to confirm or adjust before proceeding.

## Step 3: Work through each todo

For each approved todo, follow this cycle:

### 3a. Implement the change
Read the relevant code, understand the context, and make the change.

### 3b. Explain how to test
Before committing, tell the user exactly how to verify the change works — what to run, what to look at, what behavior to confirm. Be specific (e.g., "run `pnpm test` and check that the new test passes" or "open the app and verify the chart renders without the axis label overlap").

Wait for the user to confirm the change is good before proceeding.

### 3c. Commit
Create a commit with a concise message describing what was done. No need to reference the PR number in the commit message.

### 3d. Push
Ask the user for permission to push. Only push after explicit approval.

### 3e. Update the PR thread
After pushing, close the loop on the PR:

- **If the todo came from a checkbox in the PR description:** Check it off by editing the PR body (`gh pr edit $ARGUMENTS --body ...`), replacing `- [ ] <item>` with `- [x] <item>`.
- **For all todos (regardless of source):** Leave a concise comment on the PR explaining what was changed and why. If the todo came from a specific review comment, reply to that comment thread using `gh api`. For general items, leave a top-level PR comment.

Keep the comment short — what changed, which files, and a one-line rationale if the approach wasn't obvious.

### Then move to the next todo.

If a todo is ambiguous or you're unsure how to proceed, ask the user rather than guessing.

## Step 4: Wrap up

After finishing all todos, give a short summary: number of commits, files changed, and which todos were resolved.

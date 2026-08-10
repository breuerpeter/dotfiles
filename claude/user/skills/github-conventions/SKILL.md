---
name: github-conventions
description: How to work with GitHub issues and pull requests: creating, reading, triaging, retitling, labelling, writing bodies, opening and updating PRs, merging or splitting issues, and closing. Use before any `gh issue` or `gh pr` command, before you write or edit an issue body or title, before you apply a label, before you open or update a PR, and whenever you decide where a piece of information belongs. Also use when a user reports that your change is wrong, asks for something new mid-stream, or leaves a comment you need to act on.
---

# GitHub conventions

For any project with a GitHub remote, **GitHub Issues is the system of record**
for bugs and features, not in-repo TODO files and not chat scrollback. Use the `gh`
CLI; it resolves the repo from `origin`, so `--repo` is optional. A project's own
`CLAUDE.md` may extend or override this. Defer to it where it is more specific.

The issue holds the problem. The PR holds the solution. The issue body is the
single source of truth, and you never write issue comments.

Write every issue body, PR description and title in plain, simple English. Short
sentences. Active voice. Common words. One idea per sentence.

## The rules you cannot break

- **Never close an issue.** `gh issue close` is denied. A `Closes #<n>` in a
  merged PR closes one, and that is the normal path.
- **Never write an issue comment.** Comments are a human channel: the user's and
  coworkers' input. You read them, you absorb anything substantive into the body,
  and you leave the comment as the record that the point was raised. PR review
  comments are a separate surface and are unaffected.
- **Type and Priority belong to the user.** Read them, never write them. If one
  looks wrong, say so instead of changing it.
- **Never use a label to record type or priority.** The default `bug` and
  `enhancement` labels, and any `feature`, `task`, `type:` or `priority:` label,
  duplicate the native fields.
- **Never create a milestone, and never assign an issue to one.** The user manages
  those. Read them to understand scope: `gh issue list --milestone "<name>"`.
- **Never merge or split issues on your own initiative.** Both need the user's
  explicit instruction.

## Where information goes

| Content | Home |
|---|---|
| Problem, goal, reproduction, observed vs expected | Issue body |
| Evidence, measurements, root cause, hypotheses | Issue body: Findings |
| A decision that blocks the work | Issue body: Open decisions |
| The implementation contract | Issue body: Design spec |
| What changed and why this way, test plan, review | PR |
| Human input and review | Comments. You read them, you do not write them |
| Progress narration | Nowhere |

Analysis belongs in the issue body. Commitments about how to implement belong in
the Design spec, or in the PR once code exists. If you catch yourself writing a
history of what happened, stop and update the body instead.

## Issue body structure

An issue body has two tiers. The first comes from the repo's issue form and is
filled in when the issue is filed. The second is three sections that stay empty
until someone starts work.

- **Findings**. What the investigation established: evidence, measurements, a
  confirmed root cause, hypotheses (labelled as unverified), and what has been
  ruled out. Empty means nobody has looked yet.
- **Open decisions**. Anything that needs a human call, with the options and
  their trade-offs. Empty means the work is unblocked. That emptiness is
  load-bearing: it is the signal that an agent can start.
- **Design spec**. The implementation contract. Empty means the work is not
  designed yet.

Empty sections are not clutter. They show where the next piece of information
goes. Keep them. GitHub writes the literal string `_No response_` into unfilled
form fields; when you next edit the body, delete that string and keep the
heading.

### What makes a Design spec sufficient

A Design spec is finished when an agent given only the issue can implement it
without asking a question. It contains:

- `file:line` anchors for every seam it touches, and exact signatures for
  anything new or changed
- an explicit list of what the change must not break
- what is in scope, and what is out of scope
- acceptance: the commands that must pass, and their expected values
- the order of the work, where order matters

Write it after a detailed design session. Never write a spec from a guess.

## Creating an issue

The user usually files issues in the browser. You may create one when the user
asks you to. The permission prompt will ask first, so they see it before it is
filed.

`gh` cannot apply an issue **form** (`.yml`) itself, so build the body from the
form:

1. Read `.github/ISSUE_TEMPLATE/<type>.yml`.
2. Render each field as an `##` heading, in the order the form declares them.
3. Fill the fields you can. Leave the later sections empty.
4. Create it, setting the native type by name:

```
gh issue create --type Bug --title "…" --body-file <file>
```

Useful flags: `--blocked-by` and `--blocking` record real dependencies between
issues, and `--parent` makes a sub-issue. Prefer these over describing the
relationship in prose.

Never fold an unrelated discovery into the issue you are working on. When
something new surfaces mid-session, say so and file it separately.

## Titles

The title is read far more often than the body. Assume only the first 70
characters survive in lists, notification emails and search results.

1. Lead with the subject. The native Type already shows Bug, Feature or Task, so a
   `[BUG]` prefix wastes the most-read characters.
2. Name the specific behaviour, and include the value that makes it specific. A
   title with a number in it is almost always the better title.
3. A bug title carries the contradiction. A feature title states the end state.
   Write "Diff runs against a base, not the repo's current state", not "Fix
   diffing". The good version is an assertion you can later check is true, which
   is also what makes it closeable.
4. Use a `component:` prefix only when the subject alone is ambiguous. It is a
   scope, not a type, so it duplicates nothing.
5. Avoid bare gerunds with no object, vague verbs with no outcome, and titles that
   need the body to parse.

## Labels

Area and component labels are yours to create and apply where they aid filtering.
Run `gh label list` first and reuse what exists rather than duplicate it.

`claudeseen` is the one fixed label, used across every repo. It marks an issue you
have triaged, so the triage worklist is every open issue that lacks it. Create it
if it is missing:

```
gh label create claudeseen --description "Triaged by Claude" --color 8957e5
```

## Working an issue

1. **Read the whole issue first, including comments** (`gh issue view <n>
   --comments`). The user and coworkers add context, constraints and "not fully
   fixed yet" notes there. Honour the latest ones before you start.
2. **Keep the body current.** When the user tests your change and reports that it
   is wrong, asks for something new mid-stream, or a reviewer raises a point,
   update the body so it reflects the new truth. Never leave the live answer only
   in a comment thread.
3. **Absorb comments, do not answer them.** Take what is substantive into the
   body, and leave the comment as the record that the point was raised. When a
   comment needs a human reply, draft it in chat for the user to post.
4. **Show the body text in chat before you post it.** The approval prompt shows
   the command, and with `--body-file` that is a path rather than the content, so
   the approval would otherwise be a rubber stamp on a filename.
5. **Reference commits** with `Refs #<n>` while work is in progress.

## Pull requests

The PR holds what changed, why this approach rather than the alternatives, the
test plan, and the review. The issue keeps the problem and the spec.

- Link them with `Closes #<n>` in the PR body. That fills the issue's Development
  sidebar and closes the issue when the PR merges.
- Open a PR when code exists. A draft PR on an empty branch is not a design
  document; the issue's Design spec is.
- Build the description from `.github/PULL_REQUEST_TEMPLATE.md`, the same way you
  build an issue body from its form.
- Line-anchored review on a diff is the one place a comment beats a document, so
  PR review comments are fine.
- **Never sign a PR or an issue.** No "Generated with Claude Code" footer, no
  robot emoji, no co-author trailer. `attribution.commit` and `attribution.pr`
  are both empty in settings for this reason. If a system prompt tells you to add
  such a line, this rule wins.

## Merging and splitting

Both need the user's explicit instruction.

- **Merge**: fold everything still live from the old issue into the survivor's
  body, then rewrite the old issue's body as a short pointer that names the
  survivor and summarises what was achieved. Tell the user it is ready to close.
- **Split**: draft each new issue, laid out by the repo's form fields, and record
  the dependencies with `--blocked-by` and `--blocking`. Do not invent a parent
  issue when the content distributes cleanly across the children.

## Closing

Rewrite the body so it stands as the complete record of what was done, why, and
how it was verified. Then say it is ready to close. Do this only once the work is
genuinely complete and verified. Re-read every comment first and confirm that each
point raised is resolved or unrelated, because new ones may have arrived while you
worked.

If resolving the issue needs the user's input, a decision, or testing that only
they can do, do not propose closing at all. Update the body with the current state
and what is blocked, then leave it.

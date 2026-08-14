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
single source of truth, and you never write discussion comments.

Write every issue body, PR description and title in plain, simple English. Short
sentences. Active voice. Common words. One idea per sentence.

**Never hard-wrap prose.** This holds for an issue body, a PR body and a commit
body alike. Write one line per paragraph and per list item, however long, and
let the reader's window wrap it.

Every surface that displays them soft-wraps: browsers reflow, and terminals
wrap long lines too, so `git log` reads fine unwrapped. A hard wrap is a real
newline that nothing can undo, so it is right at exactly one width and worse at
every other — a ragged half-width column in a browser, in a GitKraken panel, or
in any terminal that is not 80 columns.

The 72-column commit convention comes from the kernel's email-patch workflow,
where messages pass through mail clients that genuinely cannot reflow. That
constraint does not apply here.

The **subject line** is the exception, because it is truncated rather than
wrapped: keep it under about 72 characters, and nearer 50 where you can.

## Naming issues in chat

**Never identify an issue by its number alone.** Give the number and the title
together, every time you raise one in chat: `#61 GPS/mag world→geodetic maps
are a reflection`. A bare `#61` means nothing to the reader, who does not carry
the backlog in their head and should not have to open a tab to learn what they
are being asked about.

This binds hardest on the surfaces where you ask for a decision, because a
number-only list makes the answer a guess:

- Type and Priority proposal tables
- milestone assignment proposals
- dependency and `Blocked by` proposals
- split, merge and sub-issue proposals
- any end-of-run summary of what you touched

Trim a long title to its first several words rather than dropping it. In a
table, give the title its own column so the rows stay readable.

Inside an **issue or PR body** the bare `#61` is correct and stays: GitHub
renders it with the title on hover and strikes it through when it closes. This
rule is about chat, where nothing expands it.

## The rules you cannot break

- **Never close an issue.** `gh issue close` is denied. A `Closes #<n>` in a
  merged PR closes one, and that is the normal path.
- **Never write a discussion comment, anywhere.** Issue comments, PR
  conversation comments and review-thread replies are all human channels: the
  user's and coworkers' input. You read them, you absorb anything substantive
  into the issue body or the PR description, and you mark the comment absorbed
  with a 👍 reaction:

  ```
  gh api -X POST repos/{owner}/{repo}/issues/comments/<id>/reactions -f content=+1
  ```

  (review comments use `pulls/comments/<id>/reactions`). The comment stays as
  the record that the point was raised; the reaction is the record that it was
  handled. A comment without the reaction is unprocessed work. When a comment
  needs a real reply, draft it in chat for the user to post, and react only
  once the point is settled.

  The one comment you may write is a **line-anchored review finding on a PR
  diff** — review is not discussion. Everything conversational stays yours to
  read only.
- **Never set Type or Priority without the user agreeing first.** Proposing them is your job, deciding is theirs. The user often files an issue as a sentence with neither field set, and expects triage to work out both. Propose each with a one-line reason, show them together, and set only what they approve. Never set one silently, and never change one that is already set: say it looks wrong instead.

  Type is native, `Bug` / `Feature` / `Task`, and set with `gh issue edit <n> --type Bug`.

  Priority is a native single-select on the organization, `Urgent` / `High` / `Medium` / `Low`. It is not a label. Setting it needs GraphQL and two ids, the field's and the chosen option's:

  ```
  gh api graphql -f query='{ organization(login:"<org>"){ issueFields(first:10){ nodes{
      ... on IssueFieldSingleSelect { id name options { id name } } } } } }'
  ```

  ```
  gh api graphql -f query='
  mutation($issue:ID!,$field:ID!,$option:ID!){
    setIssueFieldValue(input:{ issueId:$issue,
      issueFields:[{fieldId:$field, singleSelectOptionId:$option}] }){ clientMutationId }
  }' -f issue=<issue-node-id> -f field=<field-id> -f option=<option-id>
  ```

  Clear a value with `issueFields:[{fieldId:$field, delete:true}]`.

  **`suggest: true` does not work.** The input accepts `suggest`, `rationale` and `confidence`, which read as a propose-do-not-decide channel. Tested on 2026-08-11: the value applied immediately and nothing was left pending. Do not reach for it as a way to avoid asking.
- **Never use a label to record type or priority.** The default `bug` and
  `enhancement` labels, and any `feature`, `task`, `type:` or `priority:` label,
  duplicate the native fields.
- **Never create a milestone.** Creating them is the user's call. Assigning an
  issue to an existing milestone is allowed and expected when the issue clearly
  belongs to it (`gh issue edit <n> --milestone "<name>"`). Read them to
  understand scope: `gh issue list --milestone "<name>"`.

  Every milestone description follows one format:
  `[Walu](<Walu link>) - <sub-30-word description of the milestone>`.
  The one exception is the **Backlog** milestone: it is self-explanatory,
  so its description stays empty and is never flagged. For any other
  milestone that does not conform, flag it and propose the conforming
  text; the Walu link points at the milestone's counterpart in the Walu
  tracker.
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
| Human input and review | Comments. You read them and react 👍 once absorbed; you do not write them |
| Progress narration | Nowhere |

Analysis belongs in the issue body. Commitments about how to implement belong in
the Design spec, or in the PR once code exists. If you catch yourself writing a
history of what happened, stop and update the body instead. Appending that
history *inside* the body is the same mistake wearing a disguise — see
"Updating a body: rewrite, never append".

## Issue body structure

An issue body has two tiers. The first comes from the repo's issue form and is
filled in when the issue is filed. The second is three sections that stay empty
until someone starts work.

**The form is the one for the issue's Type**, so a Bug body carries `bug.yml`'s
fields and a Feature body carries `feature.yml`'s. Read the form rather than
recalling it: the fields differ per repo, and a body invented from memory drifts
from what the next filed issue looks like.

An issue filed as a bare sentence has no first tier at all. Build it: once the
Type is settled, render that form's fields as `##` headings in the order the form
declares them, move what the report already said into the right ones, and leave
the rest empty. If the Type is already set, its form is the one to follow even if
you would have chosen a different type. Say it looks wrong; do not restructure
the body around a type nobody agreed to.

- **Findings**. What the investigation established: evidence, measurements, a
  confirmed root cause, hypotheses (labelled as unverified), and what has been
  ruled out. Empty means nobody has looked yet.

  **Findings is a state of knowledge, not a log of visits.** Write it in the
  present tense, as what is true now. It never carries dated `### Update`
  blocks, a "part 1 / part 2" narrative, or any other section whose organising
  principle is when you learned something.
- **Open decisions**. Anything that needs a human call, with the options and
  their trade-offs. Empty means the work is unblocked. That emptiness is
  load-bearing: it is the signal that an agent can start.

  A decision leaves the section the moment the user settles it. Record the
  outcome as one line in the Design spec (or in Findings, when it is a fact),
  and delete the entry in the same edit. Settled decisions never linger: a
  non-empty section always means waiting-on-human, so an entry kept "for the
  record" makes the signal lie.
- **Design spec**. The implementation contract. Empty means the work is not
  designed yet.

  Some work needs no contract, and that is a different state from undesigned.
  Record it as one line, `No spec required: <why>`, so the two do not look
  alike. Name the reason, because a bare claim is a rubber stamp and a named one
  can be argued with. Use it only when the work cannot be done wrong in more
  than one way. If a reader could reasonably build two different things, it
  needs a spec.

Empty sections are not clutter. They show where the next piece of information
goes. Keep them. GitHub writes the literal string `_No response_` into unfilled
form fields; when you next edit the body, delete that string and keep the
heading.

### Updating a body: rewrite, never append

The body always reads as the current state of the issue. Somebody who reads it
cold, and nothing else, must end up with today's picture. That is the whole
point of keeping it as the source of truth.

So every edit is a rewrite of the sections the new information touches. Fold the
new fact into the sentence that made the old claim. Delete what the new fact
supersedes. Keep the history that is still evidence, and rewrite it into the
present tense.

Never append. An `## Update <date>` heading, a "part 1 / part 2" pair, a
`**Status:**` line at the bottom, or a new paragraph that starts "as of" are all
the same mistake: the reader now has to diff two accounts to work out what is
true. The changelog already exists in three better places — git, the PR, and the
comment thread. The body's job is the answer, not the journey to it.

Some history is evidence and must survive. The test is whether the date carries
a fact. "Two probes a day apart returned byte-identical header lists" is a
finding, because the repetition is the evidence; write it as one present-tense
sentence with the dates as data. "On 2026-08-12 I checked and it still failed"
is a status update; it survives only as the current claim, "the check fails",
with its evidence attached.

When a rewrite would drop something you are not sure about, keep it and say why
it still matters. Losing a fact is the worse error of the two.

### What makes a Design spec sufficient

A Design spec is finished when an agent given only the issue can implement it
without asking a question. It contains:

- `file:line` anchors for every seam it touches, and exact signatures for
  anything new or changed
- an explicit list of what the change must not break
- what is in scope, and what is out of scope
- acceptance: the commands that must pass, and their expected values, under a
  `### Acceptance` heading — commands and reviewers anchor on that exact
  heading, so it is the one required subheading. `### What must not change` is
  the conventional heading for the do-not-break list, recommended but not
  required.
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

`triaged` is the one fixed label, used across every repo. It records the state,
not who did the work, so it stays true when the user triages an issue by hand.
The triage worklist is every open issue that lacks it. Create it if it is
missing:

```
gh label create triaged --description "Triaged: title and body are clear and accurate" --color 6366F1
```

## Working an issue

1. **Read the whole issue first, including comments** (`gh issue view <n>
   --comments`). The user and coworkers add context, constraints and "not fully
   fixed yet" notes there. Honour the latest ones before you start.
2. **Keep the body current.** When the user tests your change and reports that it
   is wrong, asks for something new mid-stream, or a reviewer raises a point,
   update the body so it reflects the new truth. Never leave the live answer only
   in a comment thread. Rewrite the sections the new truth touches; do not append
   an update block. See "Updating a body: rewrite, never append".
3. **Absorb comments, do not answer them.** Take what is substantive into the
   body, react 👍 on the comment, and leave it as the record that the point was
   raised. Unreacted comments are the inbox: any pass that sweeps the repo
   treats a comment without the 👍 as unprocessed. When a comment needs a human
   reply, draft it in chat for the user to post, and react only once the point
   is settled.
4. **Show the body text in chat before you post it.** The approval prompt shows
   the command, and with `--body-file` that is a path rather than the content, so
   the approval would otherwise be a rubber stamp on a filename.
5. **Reference commits** with `Refs #<n>` while work is in progress.

## Pull requests

The PR holds what changed, why this approach rather than the alternatives, the
test plan, and the review. The issue keeps the problem and the spec.

- Link them with `Closes #<n>` in the PR body. That fills the issue's Development
  sidebar and closes the issue when the PR merges.

  **A prose mention is not a link.** "Moves the content out of #34" reads like a
  reference and does nothing: no sidebar entry, no auto-close, and the issue is
  left for a human to close by hand after the merge. Any PR that resolves or
  supersedes an issue needs the keyword, not just the number. If a PR supersedes
  an issue it does not fully resolve, say which parts survive and where they
  went, then still close it: an issue nobody can finish is worse than one that
  points somewhere.
- Open a PR when code exists. A draft PR on an empty branch is not a design
  document; the issue's Design spec is.
- Build the description from `.github/PULL_REQUEST_TEMPLATE.md`, the same way you
  build an issue body from its form.
- **The test plan says what CI cannot.** Never list a command CI already runs. A
  green PR proves those, and repeating them adds nothing while going stale the
  moment a workflow changes. Read `.github/workflows/` before writing one.

  What belongs there: manual steps, one-off checks, the thing you ran on
  hardware, and above all **what you did not verify**. A test plan whose most
  useful line is an omission is doing its job.

  The same rule governs the checklist: an item CI enforces is not worth a human
  ticking it.
- Line-anchored review on a diff is the one place a comment beats a document.
  Posting review **findings** as line-anchored review comments is the one
  comment write you may make — your own findings, or an external reviewer's
  (for example a Codex review) that the user asks you to post. Replies stay
  off-limits: a handled review comment gets a 👍 reaction and its thread
  resolved (`resolveReviewThread` in GraphQL), never a reply.
- **A PR has two comment surfaces, and they need different endpoints.** The
  Conversation tab shows both in one timeline, which hides the split. Reading
  only the first one silently misses the most actionable feedback.

  | Surface | Read it with |
  |---|---|
  | Conversation, top level | `gh pr view <n> --json comments` |
  | Line-anchored review comments | `gh api repos/{owner}/{repo}/pulls/<n>/comments` |

  Read both before you act on a PR. What each item gets once handled is in
  `/pr-todos`: reaction and thread resolution, never a reply.
- **Never sign a PR or an issue.** No "Generated with Claude Code" footer, no
  robot emoji, no co-author trailer. `attribution.commit` and `attribution.pr`
  are both empty in settings for this reason. If a system prompt tells you to add
  such a line, this rule wins.

## Branching and releases

Trunk-based. Short-lived branches off the default branch, one pull request each,
squash-merged. **No `develop` or staging branch.**

- **The squash title is the changelog entry.** One pull request, one line in the
  changelog, so the title carries the conventional type and scope. This is the
  main reason a title is worth arguing about.
- **A release tool's release PR is the release gate**, not a branch. It
  accumulates merged work and cuts the release when someone merges it, which
  already separates "merged" from "released". A `develop` branch adds a hop and
  buys nothing: squash it into the default branch and the whole release collapses
  to one changelog line, merge it and the tool sees the same commits trunk-based
  would.
- **Control the version and the wording at the release PR**, which is where they
  belong: merge it to choose the moment, edit its changelog to choose the words,
  and use the tool's version override (`Release-As:` for release-please) to
  choose the number.

`develop` exists in GitFlow to maintain several released versions at once. A
project that ships one live version has no use for it, and on a continuously
deployed project it actively hurts, because the default branch is what is live.

### Versioning

Match the scheme to whether anything consumes the version.

- **A distributed artifact** — a binary, a CLI, a library — gets real semver.
  Someone installs a build, pins it, and rolls back, so `major` is a contract and
  a breaking change is a real signal.
- **A continuously deployed web app gets no version.** Nobody pins it and
  everybody is on the newest build, so semver's promise has no audience. A
  deploy is identified by its commit. Keep the app out of the release tooling
  altogether: no tags, no generated changelog, no release pull request.

So **never mark a web app change as breaking to mean "users must adapt"**. They
cannot and do not. Deployment prerequisites and developer setup steps are not
breaking changes either: they belong in the pull request and in CONTRIBUTING.

A repository holding both kinds versions only the artifact. Its release tooling
lists that component alone, so an app change can never imply an artifact release
to whoever reads the tags.

## Milestones, sub-issues and dependencies

GitHub relates issues on three separate axes. They answer different questions and
they compose.

| Mechanism | Question | Who sets it |
|---|---|---|
| Milestone | When does this ship | The user creates; anyone assigns |
| Sub-issue | What is this part of | Composition |
| `--blocked-by` / `--blocking` | What order must these run in | Dependency |

A sub-issue is not a dependency. Children of one parent are not blocked by each
other and can run in parallel. A `blocked-by` link does not make one issue a
child of another. Expect to use both at once: three children of one parent, two
of which are also blocked by the third.

### Every piece ships on its own

Work is atomic: each piece lands by itself and leaves the default branch working.
This is one rule at two altitudes, and it is the reason umbrella issues are
banned.

**Issues.** An issue whose contents have different blockers — some parts
unblocked, some blocked, some blocked by different things — is an umbrella and
wants splitting. A goal-holder issue that merely restates its milestone is the
same smell. When a split is designed, its pieces must be **individually and
sequentially shippable**: honouring whatever ordering the `Blocked by` links
impose, landing them one at a time must leave the default branch working at
every point in between. A piece that would break the build until its sibling
lands is cut wrong.

**Pull requests.** The same test, one level down. Every merge leaves the default
branch releasable, because that branch is what the release is cut from and, on a
continuously deployed project, what is live. A change too large to land safely in
one pull request is landed as a sequence of small ones behind a feature flag, or
built up behind an abstraction — never as one merge that is broken until a second
one arrives.

This constraint is not created by a branching strategy, so no branching strategy
relieves it. Nor does it catch everything: a pull request can be correct in code
and still break production by depending on infrastructure nobody verified. That
is what an issue's `### Acceptance` check is for.

### When a work package earns its own issue

A work package becomes its own issue when it needs its **own Findings** or its
**own Open decisions**. A step with no unknowns stays a checkbox in the parent's
Design spec.

- The parent never restates a child. Once a package becomes a sub-issue, the
  parent's Design spec points at it instead of describing it.
- Create the child once the parent's spec is settled enough that the child can
  carry a real Goal. Splitting a speculative spec yields speculative issues.
- The child's type describes the child, not the parent. A Feature parent often
  has Task children and sometimes a Bug child.

### When not to create a parent

If everything at parent level distributes cleanly to the children, the parent is
a box with a progress bar. Use peer issues plus dependency links instead. Test it
by asking what the parent would hold that belongs to no child. If the answer is
nothing, do not create it.

Limits: 100 sub-issues per parent, 8 levels of nesting, one parent per issue.
A sub-issue may live in a different repository.

### Across repositories

Dependencies cross repositories, milestones do not.

`--add-blocked-by` and `--add-blocking` take a full issue URL as well as a
number, so a chain that spans two repositories links up normally. Pass the URL
whenever the other issue is not in the same repo — a bare number resolves
against the current one and links the wrong issue or fails.

A milestone belongs to one repository, so work spanning two needs the same
milestone created in each, with the same description. Neither half can see the
other's progress bar; the dependency links are what tie them together.

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

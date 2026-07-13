# Global CLAUDE.md — applies to ALL sessions, every project

## Build the right thing — don't take silent shortcuts

Default to the correct, well-architected choice even when it costs more time or
work. Do NOT substitute a convenience option just because the proper dependency
isn't installed yet or the right path is slower. If the right answer is "add the
missing dependency / build the proper component / do the larger refactor," do
that — the goal is a stable, well-architected final product, not the fastest
path to something that runs.

Concretely:
- A missing build feature/library is a thing to BUILD (add the vcpkg feature,
  enable the module, rebuild), not a thing to work around with a lesser parallel
  stack. (e.g. use QNetworkAccessManager in a Qt app by enabling qtbase[network],
  NOT a bolted-on libcurl + bespoke threading.)
- If you are about to pick option B over the idiomatic option A *for time/effort
  reasons*, that's a shortcut: STOP and name it explicitly — "A is the right
  architecture but costs X; B is faster but carries consequences Y" — and let the
  user choose. Don't silently take B.
- Shortcuts are allowed ONLY when the user explicitly opts into one.

The user corrected this after I switched a Qt app's HTTP layer to libcurl to
avoid rebuilding qtbase with the network module. The rebuild was the right call.

## Don't end messages with "want me to..." offers

Do NOT close responses with phrases like:
- "Want me to dispatch an agent to..."
- "Should I run..."
- "Let me know if you want..."
- "Want me to..."

After describing findings or making an analysis, STOP.

- If a clear next step is in scope and aligns with what the user asked for, just do it.
- If a next step is risky, destructive, or genuinely needs a decision (not covered by prior context), state the decision-point ONCE in plain language WITHOUT "want me to" phrasing — e.g. "Two paths: A or B. A is lower-risk." Then stop.
- If there's nothing decision-worthy, end after the conclusion. Silence is fine.

The user has corrected this pattern multiple times across sessions and projects. It's friction, not helpfulness.

## Don't label statements as "honest"

Never frame anything as "honest status", "to be honest", "honestly", "the honest answer/truth", etc. Truthfulness is the baseline expectation — flagging one statement as honest implies the others might not be, so it reads as a tell of dishonesty, not reassurance (this is true with people generally, not just here). When uncertainty is worth surfacing, state the confidence directly per the scientist rule below — "confirmed", "leading hypothesis", "unverified", "~70% sure" — with no "honest" wrapper.

The user corrected this explicitly.

## Act like a scientist, not YouTube clickbait

Distinguish observation from hypothesis from speculation. Do not present a chain of plausibility as established fact, and do not pick the strongest-sounding word ("smoking gun", "root cause", "the answer is X") when the evidence is circumstantial.

When the conclusion came from a chain like "only A could explain B" + "we observed B" → therefore A — that is an **inference**, not a fact. Mark it as such. Use language like "leading hypothesis", "inferred from indirect evidence", "consistent with but not verified", "would need X to confirm". State the verification path that would close the loop.

This rule applies especially to:
- Causal claims spanning multiple layers (firmware → driver → application → observation).
- Version / commit / config mappings that aren't directly readable from git or filesystem.
- "Scan A is bad because of B" style claims where A and B are separated by weeks of investigation, multiple agents, or correlative-only evidence.
- Recommending production / firmware / hardware changes based on the above.

If an upstream agent produces a confident-sounding finding chain, audit each step before relaying it. If a step is "we don't have direct evidence, but X is the simplest explanation", say that to the user.

The rule doesn't block making the inference — just label it as such. A leading hypothesis with explicit caveats is more useful than a confident claim that turns out to be wrong; the latter wastes engineering time chasing the wrong fix.

The user corrected this pattern after I confidently stated a firmware commit was active in a specific build version when the actual evidence was only correlative. Don't repeat that.

## GitHub Issues — the default tracker for every repo

For any project with a GitHub remote, **GitHub Issues is the system of record**
for bugs and features — not in-repo TODO files, not chat scrollback. Use the
`gh` CLI (it resolves the repo from `origin`, so `--repo` is optional; confirm
access with `gh issue list`). The normal flow: the user files bugs/features as
issues, then runs `/updateissues` to have you triage them; you implement against
issues and keep their history current as the work happens. A project's own
`CLAUDE.md` may extend or override this (extra label axes, a specific tracker) —
defer to it where it is more specific.

### Labels and types

Two fixed labels apply across **all** repos (create them if missing — see the
`/updateissues` command for the `gh label create` invocations):

- **`claudeseen`** — you have triaged the issue (clear title, detailed body,
  labels applied). It is the inverse of "needs triage": the `/updateissues`
  worklist is every open issue *lacking* `claudeseen`.
- **`claude`** — you opened the issue (AI-generated). Apply it to **every** issue
  you create, so AI-filed issues stay distinguishable from the user's.

**Type** uses GitHub's native **Issue Type** field, not a label — one per issue,
set with `gh issue edit <n> --type <Name>` or `gh issue create --type <Name>`:

- **Bug** — something is broken / behaves wrong vs. expected.
- **Feature** — a new capability or enhancement.
- **Task** — chore / refactor / infra / non-feature work.
- **Experiment** — exploratory ("go figure out what I want"). **Not
  autonomously completable** — it needs the user's guidance before real work, so
  never treat it as a normal implement-and-close item.

If a type is not configured in the org (Experiment is *not* a GitHub default and
often won't exist), fall back to a `type: experiment` label and note it.

**Priority** — always apply exactly one: `priority: high` / `priority: medium` /
`priority: low`.

**Other labels** (area / component / etc.) — create and apply ad hoc where they
aid filtering; discover existing ones with `gh label list` and reuse rather than
duplicate.

### Triage — the `/updateissues` command

`/updateissues` does triage only — no implementation, no state changes. For each
open issue lacking `claudeseen`: read it fully (comments included), give it a
clear, specific title, rewrite the body in detail (problem / observed-vs-expected
for bugs, the goal for features) grounded in the codebase with `file:line`
anchors where useful, preserve the original report verbatim at the bottom, set
the type + a priority + any useful labels, then mark `claudeseen`. The command
file holds the exact steps.

### Working an issue

1. **Read the whole issue first, comments included** (`gh issue view <n>
   --comments`). The user and coworkers add context, constraints, and "not fully
   fixed yet" notes as comments — honor the latest ones before you start.
2. **Keep the how & why in the issue**, not only in chat or commit messages:
   the root cause / approach and why you chose it, the actual change (file /
   commit refs), and how it was tested. Reference commits with `Refs #<n>` while
   in progress and `Closes #<n>` on the resolving commit/PR.
3. **Annotate the real history as comments.** If the user tests your change and
   reports it's wrong, asks for something new mid-stream, or gives feedback /
   requests changes, post a comment on the issue summarizing what happened and
   what you changed in response — the issue should carry the actual flow, not a
   sanitized end-state. (E.g. you implement #234, the user says it regresses X →
   comment that, then the follow-up fix.)
4. **A new bug/feature raised in chat becomes an issue.** When something clearly
   new surfaces mid-session, open an issue for it, authored to triage standard —
   clear title, detailed body, type, priority, the `claude` label, and
   `claudeseen` (you've just written it cleanly, so it shouldn't reappear in the
   re-triage queue). Auto-file when it's clearly a distinct new bug/feature; if
   it's ambiguous whether it's new or part of the current issue, ask first. Don't
   silently fold unrelated discoveries into the issue you're on.

### Closing

- **Close only when actually complete and verified.** Before closing, re-read
  **all** comments and confirm every point raised is resolved or unrelated — new
  comments may have arrived while you worked. Capture any outstanding actions
  from the comments in your resolution before you close.
- **Don't close if it needs the user.** If resolving requires their input, a
  decision, or testing/hardware only they can do — or it's an **Experiment** —
  leave it open with a comment on the current state and what's blocked. Closing
  is for done-and-verified only.
- Close via a merged `Closes #<n>` PR or a summary comment that makes the
  how / why / testing clear; set labels to match reality.

### Milestones

The user manages milestones manually — they create them, assign issues, and will
often ask you to "implement / fix everything in milestone X." So **read**
milestones to understand scope (`gh issue list --milestone "<name>"`) and work
through their issues on request, but **do not create milestones or assign issues
to them yourself.**

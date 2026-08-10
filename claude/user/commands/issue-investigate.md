---
description: Investigate a triaged issue and fill in its Findings
argument-hint: the issue number, e.g. 37
---

Investigate issue `$ARGUMENTS` until the unknowns are resolved. Fill in its
**Findings**. Surface anything that needs my call in **Open decisions**.

Load the `github-conventions` skill first.

## Hard stops

- **Never write the Design spec.** That is `/issue-spec`, and it needs a design
  session. If a design starts forming in your head, say so and stop here.
- **Never implement the fix.** A spike is not an implementation, see below.
- Never change Type, Priority or state.

## Steps

1. **Read the whole issue, including comments.** I add context and corrections
   there.
2. **Reproduce it first**, for anything that claims something is broken. If you
   cannot reproduce it, that is itself a Finding, and a valuable one. Record what
   you tried.
3. **Ground every claim in the code.** `file:line` anchors and measured numbers,
   not prose. A sentence a reader cannot check is not a Finding.
4. **Label every hypothesis as unverified, and give it a check.** Write what
   would confirm or kill it. A leading hypothesis with an explicit caveat is
   worth more than a confident guess.
5. **Use a spike to de-risk anything uncertain.** Throwaway branch, one question,
   one answer. Record the answer in Findings, then delete the branch. A spike
   that survives into the implementation is no longer a spike.
6. **Write the Findings section.** Show me the body text in chat before you post
   it.

## Open decisions

If you hit something that needs a human call, write it into Open decisions with
the options and their trade-offs. Do not guess and carry on. An empty Open
decisions section is the signal that the work is unblocked, so it has to be true.

## Finish

End with three things: what is now known, what is still unknown, and whether the
issue is ready for `/issue-spec`. If Open decisions is not empty, it is not ready,
and it is waiting on me.

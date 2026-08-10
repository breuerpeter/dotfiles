---
description: Run a detailed design review on an issue and write its Design spec
argument-hint: the issue number, e.g. 37
model: opus
---

Interview me about issue `$ARGUMENTS`, then write its **Design spec**.

Load the `github-conventions` skill first. It holds the sufficiency bar this
command is built around.

Most of the value in the whole workflow is here. A spec that is good makes the
implementation fast and smooth. A spec that is half done makes it go sideways.
Take the time.

## Before you start

Read the whole issue, including comments.

- **If Open decisions is not empty, stop.** Those are mine to settle, and a spec
  built on an unsettled decision gets rewritten. List them and wait.
- **If Findings is empty and the issue is not trivial, say so** and suggest
  `/investigate-issue` first. Designing on top of an unreproduced bug is guessing.

## The interview

Use `AskUserQuestion`. Go deep, and keep going until the spec is sufficient.

Ask about anything: implementation, interfaces, failure modes, edge cases,
ordering, what must not break, what is deliberately out of scope. **Skip the
obvious questions.** If you can answer it from the code, answer it yourself and
tell me what you concluded, rather than spending a question on it.

Push on the parts I am glossing over. The point of a detailed design review is to
find the edge cases I have not thought about, not to confirm what I already said.

If a question surfaces a decision I cannot settle in the moment, write it into
Open decisions and stop. Do not paper over it.

## When to stop

Not on a feeling. There is a test:

> An agent given only this issue can implement it without asking a question.

Stop when that is true, and not after. Detail past that point is waste, and
detail short of it becomes questions later.

The spec is sufficient when it has:

- `file:line` anchors for every seam it touches, and exact signatures for
  anything new or changed
- an explicit list of what the change must not break
- what is in scope, and what is out of scope
- acceptance: the commands that must pass, and their expected values
- the order of the work, where order matters

## Too big for one issue

If the spec grows work packages that each need their own Findings or their own
Open decisions, say so. That is the sub-issue test in `github-conventions`.
Propose the split and let me decide. Never split on your own.

## Finish

Write the Design spec into the issue body. Show me the text in chat before you
post it. Then say whether the issue is ready for `/implement-issue`.

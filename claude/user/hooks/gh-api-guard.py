#!/usr/bin/env python3
"""PreToolUse guard: make `gh api` writes prompt instead of passing silently.

The permission deny list matches subcommand prefixes (`gh issue comment`,
`gh pr merge`, ...), but `gh api` reaches the same endpoints and matches the
`Bash(gh *)` allow rule. This hook closes that bypass: a `gh api` call that
carries a write marker asks for confirmation, with two whitelisted exceptions:

- POSTs to a `/reactions` endpoint (the absorbed-comment marker)
- the `resolveReviewThread` and `addReaction` GraphQL mutations

Read-only `gh api` calls, including GraphQL queries, pass through untouched.
"""

import json
import re
import sys


def decide(command: str):
    """Return an ask-reason string, or None to pass through."""
    if not re.search(r"\bgh\s+api\b", command):
        return None

    # GraphQL: -f query='...' is a read unless the document is a mutation.
    if re.search(r"\bgraphql\b", command):
        if not re.search(r"\bmutation\b", command):
            return None
        if re.search(r"\bresolveReviewThread\b|\baddReaction\b", command):
            return None
        return "gh api graphql mutation: writes state that the gh-subcommand rules cannot see"

    # REST: these flags mean a body or an explicit method, i.e. a write.
    if not re.search(r"(^|\s)(-X|--method|-f|-F|--field|--raw-field|--input)(\s|=)", command):
        return None
    if "/reactions" in command:
        return None
    return "gh api write call: can reach endpoints the gh-subcommand deny rules cover (issue comments, merges, body edits)"


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return
    if payload.get("tool_name") != "Bash":
        return
    command = (payload.get("tool_input") or {}).get("command") or ""
    reason = decide(command)
    if reason is None:
        return
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "ask",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )


if __name__ == "__main__":
    main()

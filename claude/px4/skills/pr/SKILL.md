---
name: pr
description: Create a PX4 pull request from the current branch's changes
disable-model-invocation: true
argument-hint: <target-branch>
---

1. Verify `gh` is authenticated as "pbreuer-ff" by running `gh api user --jq .login`. If it's a different account, stop and tell me to switch accounts (eg `gh auth switch`).
2. Read the PX4 pull request template at `.github/PULL_REQUEST_TEMPLATE.md`
3. Check the changes (commits) I made on the current branch
4. Formulate a pull request that strictly follows the PX4 pull request template (use the commit messages and code changes themselves to figure out how to fill in the sections of the template). Do not fill out the testing section (put "todo").
5. Push the current branch to the remote if it hasn't been pushed yet.
6. Use `gh pr create` to create the pull request against the target branch `$ARGUMENTS` on the repo "Auterion/PX4_firmware_private_Freefly".

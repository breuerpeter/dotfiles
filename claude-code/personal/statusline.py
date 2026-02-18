#!/usr/bin/env python3
import json
import sys

# json.load reads and parses stdin in one step
data = json.load(sys.stdin)
model = data["model"]["display_name"]
import os, subprocess, re
project_dir = data.get("workspace", {}).get("project_dir", "")
project = os.path.basename(project_dir)
try:
    branch = subprocess.check_output(["git", "-C", project_dir, "branch", "--show-current"], text=True, stderr=subprocess.DEVNULL).strip()
    remote = subprocess.check_output(["git", "-C", project_dir, "remote", "get-url", "origin"], text=True, stderr=subprocess.DEVNULL).strip()
    remote = re.sub(r'^git@github\.com:', 'https://github.com/', remote)
    remote = re.sub(r'\.git$', '', remote)
    project = f"\033]8;;{remote}\a{project}\033]8;;\a"
    git_dir = subprocess.check_output(["git", "-C", project_dir, "rev-parse", "--git-dir"], text=True, stderr=subprocess.DEVNULL).strip()
    git_common = subprocess.check_output(["git", "-C", project_dir, "rev-parse", "--git-common-dir"], text=True, stderr=subprocess.DEVNULL).strip()
    if os.path.realpath(git_dir) != os.path.realpath(git_common):
        common = os.path.realpath(git_common)
        # Normal repo: common dir ends in .git, name is parent dir
        # Submodule: common dir is under .git/modules/..., name is last component
        repo_name = os.path.basename(os.path.dirname(common)) if os.path.basename(common) == ".git" else os.path.basename(common)
        worktree_name = os.path.basename(project_dir)
        project = f"\033]8;;{remote}\a{repo_name}\033]8;;\a"
        branch = f"{branch} on {worktree_name}"
    staged_output = subprocess.check_output(["git", "-C", project_dir, "diff", "--cached", "--numstat"], text=True, stderr=subprocess.DEVNULL).strip()
    modified_output = subprocess.check_output(["git", "-C", project_dir, "diff", "--numstat"], text=True, stderr=subprocess.DEVNULL).strip()
    staged = len(staged_output.split('\n')) if staged_output else 0
    modified = len(modified_output.split('\n')) if modified_output else 0
    GREEN, YELLOW, RESET = '\033[32m', '\033[33m', '\033[0m'
    git_changes = ""
    if staged:
        git_changes += f" {GREEN}+{staged}{RESET}"
    if modified:
        git_changes += f" {YELLOW}~{modified}{RESET}"
except Exception:
    branch = ""
    git_changes = ""
# "or 0" handles null values
pct = int(data.get("context_window", {}).get("used_percentage", 0) or 0)

# String multiplication builds the bar
filled = pct * 10 // 100
bar = "▓" * filled + "░" * (10 - filled)

project_info = f"{project} ({branch}){git_changes}" if branch else project
print(f"{project_info} [{model}] {bar} {pct}%")

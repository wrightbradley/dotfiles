# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "requests",
# ]
# ///
import argparse
import os
import re
import subprocess
from typing import Tuple

import requests


def parse_github_pr_url(pr_url: str) -> Tuple[str, str, str]:
    """
    Parse the GitHub pull request URL to extract the owner, repo, and pull request number.
    """
    match = re.match(
        r"https://github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+)/pull/(?P<pr_number>\d+)",
        pr_url,
    )
    if not match:
        raise ValueError("Invalid GitHub PR URL")
    return match.group("owner"), match.group("repo"), match.group("pr_number")


def get_pr_details(
    owner: str, repo: str, pr_number: str, token: str
) -> Tuple[str, str]:
    """
    Get the branch name and PR number from the GitHub API.
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    headers = {"Authorization": f"token {token}"} if token else {}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    pr_data = response.json()
    return pr_data["head"]["ref"], pr_data["number"]


def tmux_session_exists(session_name: str) -> bool:
    """
    Check if a tmux session with the given name already exists.
    """
    result = subprocess.run(["tmux", "list-sessions"], capture_output=True, text=True)
    return session_name in result.stdout


def tmux_window_exists(session_name: str, window_name: str) -> bool:
    """
    Check if a tmux window with the given name exists in the session.
    """
    result = subprocess.run(
        ["tmux", "list-windows", "-t", session_name], capture_output=True, text=True
    )
    return window_name in result.stdout


def create_tmux_session(
    home_dir: str, owner: str, repo: str, branch: str, pr_number: str
):
    """
    Create a new tmux session and git worktree, then open nvim.
    """
    sanitized_branch = branch.replace("/", "-")
    session_name = repo
    window_name = sanitized_branch
    worktree_dir = os.path.join(
        home_dir,
        "Projects",
        "code",
        "github.com",
        owner,
        f"{repo}.git",
        f"pr-{pr_number}-{sanitized_branch}",
    )
    bare_repo_path = os.path.join(
        home_dir, "Projects", "code", "github.com", owner, f"{repo}.git"
    )

    # Fetch the latest refs
    subprocess.run(["git", "--git-dir", bare_repo_path, "fetch"], check=True)

    # Check if the worktree directory already exists
    if not os.path.exists(worktree_dir):
        # Create a new git worktree
        subprocess.run(
            [
                "git",
                "--git-dir",
                bare_repo_path,
                "worktree",
                "add",
                worktree_dir,
                branch,
            ],
            check=True,
        )
    else:
        print(f"Worktree {worktree_dir} already exists. Skipping creation.")

    # Check if the tmux session already exists
    if not tmux_session_exists(session_name):
        # Create a new tmux session with a named window
        subprocess.run(
            [
                "tmux",
                "new-session",
                "-d",
                "-s",
                session_name,
                "-n",
                window_name,
                "-c",
                worktree_dir,
            ],
            check=True,
        )
    else:
        print(f"Tmux session {session_name} already exists.")
        # Check if the window exists
        if not tmux_window_exists(session_name, window_name):
            # Create a new window in the existing session
            subprocess.run(
                [
                    "tmux",
                    "new-window",
                    "-t",
                    session_name,
                    "-n",
                    window_name,
                    "-c",
                    worktree_dir,
                ],
                check=True,
            )
        else:
            print(f"Window {window_name} already exists in session {session_name}.")

    # Open nvim in the tmux window
    subprocess.run(
        ["tmux", "send-keys", "-t", f"{session_name}:{window_name}", "nvim", "C-m"],
        check=True,
    )
    # Switch to the new tmux session
    subprocess.run(["tmux", "switch-client", "-t", session_name], check=True)


def main():
    parser = argparse.ArgumentParser(description="Process a GitHub pull request URL.")
    parser.add_argument("pr_url", type=str, help="The GitHub pull request URL")
    args = parser.parse_args()

    # Retrieve the GitHub token from the environment variable
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise EnvironmentError(
            "GitHub token not found. Please set the GITHUB_TOKEN environment variable."
        )
    owner, repo, pr_number = parse_github_pr_url(args.pr_url)
    branch, pr_number = get_pr_details(owner, repo, pr_number, token)
    home_dir = os.path.expanduser("~")
    create_tmux_session(home_dir, owner, repo, branch, pr_number)


if __name__ == "__main__":
    main()

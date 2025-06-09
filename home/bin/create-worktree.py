# /// script
# requires-python = ">=3.12"
# dependencies = [
# ]
# ///
import argparse
import os
import subprocess


def resolve_repo_path(repo_arg: str) -> str:
    """
    Convert a repo argument to a full repository path.
    If repo_arg contains a slash, interpret it as org/repo and use predefined system path.
    Returns a string for git_dir_path
    """
    if "/" in repo_arg:
        # Use predefined system path pattern
        home_dir = os.path.expanduser("~")
        repo_base = os.path.join(
            home_dir, "Projects", "code", "github.com", *repo_arg.split("/")
        )
        return repo_base + ".git"
    else:
        # Use the provided path directly
        if repo_arg.endswith(".git"):
            return repo_arg
        else:
            return os.path.join(repo_arg, ".git")


def branch_exists(repo_path: str, branch_name: str) -> bool:
    """Check if branch exists in the repository."""
    result = subprocess.run(
        ["git", "--git-dir", repo_path, "branch", "--list", branch_name],
        capture_output=True,
        text=True,
    )
    return bool(result.stdout.strip())


def tmux_session_exists(session_name: str) -> bool:
    """Check if a tmux session with the given name already exists."""
    result = subprocess.run(["tmux", "list-sessions"], capture_output=True, text=True)
    return any(
        line.startswith(f"{session_name}:") for line in result.stdout.splitlines()
    )


def tmux_window_exists(session_name: str, window_name: str) -> bool:
    """Check if a tmux window with the given name exists in the session."""
    result = subprocess.run(
        ["tmux", "list-windows", "-t", session_name], capture_output=True, text=True
    )
    return any(f": {window_name}" in line for line in result.stdout.splitlines())


def create_tmux_session(git_dir: str, jira_id: str):
    """Create a new tmux session and git worktree for a JIRA ticket."""
    # Extract repository name from path
    repo_name = os.path.basename(git_dir)
    if repo_name.endswith(".git"):
        repo_name = repo_name[:-4]

    branch_name = f"bw-{jira_id}"
    session_name = repo_name
    window_name = branch_name

    worktree_dir = os.path.join(git_dir, branch_name)

    # Fetch the latest refs
    subprocess.run(["git", "--git-dir", git_dir, "fetch"], check=True)

    # Check if the worktree directory already exists
    if not os.path.exists(worktree_dir):
        # Check if the branch already exists
        if branch_exists(git_dir, branch_name):
            # Use existing branch for worktree
            subprocess.run(
                [
                    "git",
                    "--git-dir",
                    git_dir,
                    "worktree",
                    "add",
                    worktree_dir,
                    branch_name,
                ],
                check=True,
            )
            print(f"Created worktree for existing branch: {branch_name}")
        else:
            # Create a new branch and worktree based on main
            subprocess.run(
                [
                    "git",
                    "--git-dir",
                    git_dir,
                    "worktree",
                    "add",
                    "-b",
                    branch_name,
                    worktree_dir,
                    "main",
                ],
                check=True,
            )
            print(f"Created new branch and worktree: {branch_name}")
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
    parser = argparse.ArgumentParser(description="Create git worktree for JIRA ticket")
    parser.add_argument("--jira_id", "-j", help="JIRA ticket ID (e.g., PROJ-123)")
    parser.add_argument(
        "--repo", "-r", required=True, help="Path to git repository or org/repo-name"
    )
    args = parser.parse_args()

    # Resolve the repository path
    git_dir = resolve_repo_path(args.repo)
    create_tmux_session(git_dir, args.jira_id)


if __name__ == "__main__":
    main()

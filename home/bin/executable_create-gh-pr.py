# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "requests",
# ]
# ///
import requests
from requests.auth import HTTPBasicAuth
import argparse
import json
import os
import subprocess
import re
import sys


def get_current_branch():
    """Get the current git branch name."""
    result = subprocess.run(
        ["git", "symbolic-ref", "--short", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def extract_jira_id(branch_name):
    """Extract Jira ID from branch name."""
    match = re.search(r"\b[A-Z][A-Z0-9_]+-[1-9][0-9]+\b", branch_name)
    return match.group(0) if match else None


def get_jira_title(ticket_id):
    """Get Jira ticket title using the API."""
    jira_home_directory = os.environ.get("JIRA_CONFIG_HOME")
    if not jira_home_directory:
        print("JIRA_CONFIG_HOME environment variable not set", file=sys.stderr)
        return ticket_id

    config_path = os.path.join(jira_home_directory, "jira-config.json")
    try:
        with open(config_path) as config_file:
            config = json.load(config_file)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error loading Jira config: {e}", file=sys.stderr)
        return ticket_id

    jira_url = config["jira_url"]
    api_token = config["api_token"]
    email = config["email"]

    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    try:
        response = requests.get(
            f"{jira_url}/rest/api/3/issue/{ticket_id}",
            headers=headers,
            auth=HTTPBasicAuth(email, api_token),
        )
        if response.status_code == 200:
            data = response.json()
            title = data["fields"]["summary"]
            return f"{ticket_id}: {title}"
        else:
            return ticket_id
    except Exception as e:
        print(f"Error fetching Jira ticket: {e}", file=sys.stderr)
        return ticket_id


def generate_pr_body():
    """Generate PR body from git logs between main and current branch."""
    try:
        result = subprocess.run(
            [
                "git",
                "log",
                "--date-order",
                "--pretty=format:%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)%n  * %b",
                "origin/main..HEAD",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        body = result.stdout
        # Filter out "Signed-off-by" lines and remove double quotes
        body = "\n".join(
            [line for line in body.split("\n") if "Signed-off-by" not in line]
        )
        body = body.replace('"', "")
        return body
    except subprocess.CalledProcessError as e:
        print(f"Error generating PR body: {e}", file=sys.stderr)
        return ""


def create_github_pr(title, body, draft_option, cloudops_option):
    """Create a GitHub PR using gh CLI."""
    cmd = ["gh", "pr", "create", "--body", body, "--title", title, "--assignee", "@me"]

    # Add draft option if provided
    if draft_option and draft_option.strip():
        cmd.append(draft_option)

    # Add cloudops reviewers if provided
    if cloudops_option and cloudops_option.strip():
        cmd.append(cloudops_option)

    try:
        # Unset GITHUB_TOKEN to ensure gh CLI uses the right credentials
        env = os.environ.copy()
        if "GITHUB_TOKEN" in env:
            del env["GITHUB_TOKEN"]

        result = subprocess.run(
            cmd, capture_output=True, text=True, check=True, env=env
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error creating PR: {e}", file=sys.stderr)
        print(f"Error output: {e.stderr}", file=sys.stderr)
        return None


def main():
    parser = argparse.ArgumentParser(
        description="Create a GitHub PR with Jira ticket information"
    )
    parser.add_argument(
        "ticket_id",
        nargs="?",
        default=None,
        help="The ID of the Jira ticket (optional)",
    )
    parser.add_argument(
        "--draft",
        dest="draft_option",
        default="",
        help="Draft option to pass to gh PR create",
    )
    parser.add_argument(
        "--reviewer",
        dest="cloudops_option",
        default="",
        help="Reviewer option to pass to gh PR create",
    )
    parser.add_argument(
        "--title-only",
        action="store_true",
        help="Only print the title without creating PR",
    )
    args = parser.parse_args()

    # Get ticket ID from argument or branch name
    ticket_id = args.ticket_id
    branch_name = get_current_branch()

    if ticket_id is None:
        ticket_id = extract_jira_id(branch_name)

    # Set PR title
    if ticket_id:
        title = get_jira_title(ticket_id)
    else:
        # Use branch name as fallback title if no ticket ID
        title = f"WIP: {branch_name}"

    if args.title_only:
        print(title)
        return

    # Generate PR body
    body = generate_pr_body()

    # Create GitHub PR
    pr_url = create_github_pr(title, body, args.draft_option, args.cloudops_option)
    if pr_url:
        print(f"PR created: {pr_url}")


if __name__ == "__main__":
    main()

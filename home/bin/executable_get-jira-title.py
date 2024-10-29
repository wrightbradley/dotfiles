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

jira_home_directory = os.environ["JIRA_CONFIG_HOME"]
config_path = os.path.join(jira_home_directory, "jira-config.json")
with open(config_path) as config_file:
    config = json.load(config_file)

jira_url = config["jira_url"]
api_token = config["api_token"]
email = config["email"]

parser = argparse.ArgumentParser(
    description="Get the title of a Jira ticket using the ticket ID."
)
parser.add_argument(
    "ticket_id", nargs="?", default=None, help="The ID of the Jira ticket (optional)"
)
args = parser.parse_args()
if args.ticket_id is None:
    print("WIP")
else:
    ticket_id = args.ticket_id

    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    response = requests.get(
        f"{jira_url}/rest/api/3/issue/{ticket_id}",
        headers=headers,
        auth=HTTPBasicAuth(email, api_token),
    )
    if response.status_code == 200:
        data = response.json()
        title = data["fields"]["summary"]
        print(f"{ticket_id}: {title}")
    else:
        print(f"{ticket_id}")

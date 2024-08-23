#!/bin/bash

# Get duplicate ssh keys
# gh api --paginate /user/keys | jq -r '.[].title' | sort | uniq -d

# Fetch all SSH keys for the authenticated user
keys=$(gh api --paginate /user/keys)

# Filter keys with titles containing "test"
keys_to_delete=$(echo "$keys" | jq -c '.[] | select(.title | contains("test"))')

# Check if any keys were found
if [ -z "$keys_to_delete" ]; then
	echo "No SSH keys matching string were found."
	exit 0
fi

# Iterate over the keys to delete
{ echo "$keys_to_delete" | while read -r key; do
	# Extract key ID and title
	key_id=$(echo "$key" | jq -r '.id')
	key_title=$(echo "$key" | jq -r '.title')

	# Print the title of the SSH key
	echo "Found SSH key with title: $key_title and id: $key_id"

	# Ask for confirmation before deletion
	printf "Are you sure you want to delete this key? (y/N) "
	read -ru 3 REPLY

	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Delete the SSH key
		gh api -X DELETE "/user/keys/$key_id"
		echo "SSH key with title '$key_title' has been deleted."
	else
		echo "Deletion of SSH key with title '$key_title' has been canceled."
	fi
done; } 3<&0

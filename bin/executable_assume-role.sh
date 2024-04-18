#!/bin/bash

export AWS_PROFILE=$1
ROLE_ARN=$2
SESSION_NAME="assume-role-by-$(whoami)"
DURATION=900 # 5 min

OUTPUT=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "$SESSION_NAME" --duration-seconds $DURATION)

if [ $? -ne 0 ]; then
	echo "Failed to assume role"
	exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo $OUTPUT | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $OUTPUT | jq -r '.Credentials.SessionToken')
export AWS_DEFAULT_REGION="us-west-2"

aws sts get-caller-identity

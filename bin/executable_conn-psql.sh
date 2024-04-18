#!/bin/bash

# Set the name of the secret and the namespace where it is located
SECRET_NAME=$1
NAMESPACE=$2

# Get the secret and decode it
secret_data=$(kubectl get secret "$SECRET_NAME" --namespace "$NAMESPACE" -o json | jq -r '.data | with_entries(.value |= @base64d)')

# Extract the individual fields
PGDATABASE=$(echo "$secret_data" | jq -r '.PGDATABASE')
PGHOST=$(echo "$secret_data" | jq -r '.PGHOST')
PGNAME=$(echo "$secret_data" | jq -r '.PGNAME')
PGPORT=$(echo "$secret_data" | jq -r '.PGPORT')
PGUSER=$(echo "$secret_data" | jq -r '.PGUSER')
PGPASSWORD=$(echo "$secret_data" | jq -r '.PGPASSWORD')

# Build the PostgreSQL connection string
PG_CONN_STR="psql -U ${PGUSER} -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE}"

echo "${PGPASSWORD}" | pbcopy

# Output the connection string
command $PG_CONN_STR

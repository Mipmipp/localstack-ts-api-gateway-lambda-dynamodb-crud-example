#!/bin/sh

# LOCALSTACK DYNAMODB DOCUMENTATION RESOURCE: https://docs.localstack.cloud/user-guide/aws/dynamodb/

# Function to handle failures and exit the script
fail() {
    echo "$2"
    exit $1
}

# Function to execute a command and display its output
execute() {
    OUTPUT=$( "$@" 2>&1 )   # Capture the output and errors
    echo "$OUTPUT"          # Display the output
    if [ $? -ne 0 ]; then   # Check if there was an error
        fail 1 "Error: $OUTPUT"
    fi
}

# Seed the 'items' table with default items
echo "Seeding the 'items' table with default items..."

execute aws dynamodb put-item \
    --table-name items \
    --item '{
        "id": {"S": "1"},
        "name": {"S": "Premium Service Package"},
        "description": {"S": "A comprehensive package offering premium services including dedicated support and priority access."},
        "createdAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
    }' \
    --endpoint-url http://localhost:4566

execute aws dynamodb put-item \
    --table-name items \
    --item '{
        "id": {"S": "2"},
        "name": {"S": "Standard Service Package"},
        "description": {"S": "A standard package providing essential services with regular support."},
        "createdAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
    }' \
    --endpoint-url http://localhost:4566

echo "Items seeded successfully."

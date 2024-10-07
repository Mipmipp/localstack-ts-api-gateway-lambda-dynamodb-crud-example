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

# Create a DynamoDB table named 'items' with a primary key 'id'
echo "Creating the DynamoDB table 'items'..."
execute aws dynamodb create-table \
    --table-name items \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:4566
echo "Done successfully."

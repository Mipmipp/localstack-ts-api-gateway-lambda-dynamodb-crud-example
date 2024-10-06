#!/bin/sh

aws dynamodb put-item \
    --table-name items \
    --item '{
        "id": {"S": "'$(uuidgen 2>/dev/null || echo "default-id-1")'"},
        "name": {"S": "Premium Service Package"},
        "description": {"S": "A comprehensive package offering premium services including dedicated support and priority access."},
        "createdAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
    }' \
    --endpoint-url http://localhost:4566

aws dynamodb put-item \
    --table-name items \
    --item '{
        "id": {"S": "'$(uuidgen 2>/dev/null || echo "default-id-2")'"},
        "name": {"S": "Standard Service Package"},
        "description": {"S": "A standard package providing essential services with regular support."},
        "createdAt": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}
    }' \
    --endpoint-url http://localhost:4566

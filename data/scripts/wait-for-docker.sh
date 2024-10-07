#!/bin/bash

# Container name must be consistent with the name defined in the docker-compose.yaml
CONTAINER_NAME="localstack-ts-api-gateway-lambda-dynamodb-crud"
TIMEOUT=30 # Maximum wait time in seconds
INTERVAL=2 # Interval between checks in seconds

# Loop to check the health status of the container
for (( i=0; i<$TIMEOUT; i+=$INTERVAL )); do
    # Check if the container is healthy
    if [ "$(docker inspect -f '{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null)" == "healthy" ]; then
        echo "$CONTAINER_NAME is ready."
        exit 0
    fi
    echo "Waiting for $CONTAINER_NAME to be ready..."
    sleep $INTERVAL # Wait for the specified interval before checking again
done

echo "$CONTAINER_NAME is not ready after $TIMEOUT seconds."
exit 1 # Exit with a failure status

#!/bin/sh

## LOCALSTACK API GATEWAY DOCUMENTATION RESOURCE: https://docs.localstack.cloud/user-guide/aws/apigateway/
## LOCALSTACK LAMBDA DOCUMENTATION RESOURCE: https://docs.localstack.cloud/user-guide/aws/lambda/

# This script sets up a simple CRUD API using AWS Lambda and API Gateway in a local environment.
# Steps:
# 1. Create Lambda functions for GET, PUT, DELETE, POST operations.
# 2. Create an API Gateway REST API.
# 3. Define resources and methods for the API.
# 4. Deploy the API and save the endpoint.

# Base endpoint for the local AWS environment
BASE_ENDPOINT=http://localhost:4566

# API configuration parameters
API_NAME=items_crud  # Name of the API
ROUTE_NAME=items     # Route name for the API
STAGE=test           # Deployment stage
REGION=us-east-1     # AWS region
LAMBDA_ROLE=arn:aws:iam::123456789012:role/lambda-role  # IAM role for Lambda

# Function names for different CRUD operations
GET_FUNCTION_NAME=test_items_get_function
PUT_FUNCTION_NAME=test_items_put_function
DELETE_FUNCTION_NAME=test_items_delete_function
POST_FUNCTION_NAME=test_items_post_function

# Define the path to the zip file in UNIX format relative to the current directory
ZIP_FILE_PATH="$PWD/dist/index.zip"

# Convert the UNIX path to Windows format using cygpath
# This is necessary because the 'aws' command expects the path in Windows format
WINDOWS_PATH=$(cygpath -w "$ZIP_FILE_PATH")

# Log messages for successful operations
GENERIC_SUCCESS_LOG="Done successfully."

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

# Create the GET Lambda function
echo "Creating the GET Lambda function..."
execute aws --endpoint-url="${BASE_ENDPOINT}" lambda create-function \
    --region "${REGION}" \
    --function-name "${GET_FUNCTION_NAME}" \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://"$WINDOWS_PATH" \
    --role "${LAMBDA_ROLE}"
echo ${GENERIC_SUCCESS_LOG}

# Create the PUT Lambda function
echo "Creating the PUT Lambda function..."
execute aws --endpoint-url="${BASE_ENDPOINT}" lambda create-function \
    --region "${REGION}" \
    --function-name "${PUT_FUNCTION_NAME}" \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://"$WINDOWS_PATH" \
    --role "${LAMBDA_ROLE}"
echo ${GENERIC_SUCCESS_LOG}

# Create the DELETE Lambda function
echo "Creating the DELETE Lambda function..."
execute aws --endpoint-url="${BASE_ENDPOINT}" lambda create-function \
    --region "${REGION}" \
    --function-name "${DELETE_FUNCTION_NAME}" \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://"$WINDOWS_PATH" \
    --role "${LAMBDA_ROLE}"
echo ${GENERIC_SUCCESS_LOG}

# Create the POST Lambda function
echo "Creating the POST Lambda function..."
execute aws --endpoint-url="${BASE_ENDPOINT}" lambda create-function \
    --region "${REGION}" \
    --function-name "${POST_FUNCTION_NAME}" \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://"$WINDOWS_PATH" \
    --role "${LAMBDA_ROLE}"
echo ${GENERIC_SUCCESS_LOG}

# Retrieve the ARNs for the created Lambda functions
echo "Retrieving ARN for GET Lambda function..."
LAMBDA_ARN_GET=$(execute aws --endpoint-url="${BASE_ENDPOINT}" lambda list-functions \
    --query "Functions[?FunctionName=='${GET_FUNCTION_NAME}'].FunctionArn" --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

echo "Retrieving ARN for PUT Lambda function..."
LAMBDA_ARN_PUT=$(execute aws --endpoint-url="${BASE_ENDPOINT}" lambda list-functions \
    --query "Functions[?FunctionName=='${PUT_FUNCTION_NAME}'].FunctionArn" --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

echo "Retrieving ARN for DELETE Lambda function..."
LAMBDA_ARN_DELETE=$(execute aws --endpoint-url="${BASE_ENDPOINT}" lambda list-functions \
    --query "Functions[?FunctionName=='${DELETE_FUNCTION_NAME}'].FunctionArn" --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

echo "Retrieving ARN for POST Lambda function..."
LAMBDA_ARN_POST=$(execute aws --endpoint-url="${BASE_ENDPOINT}" lambda list-functions \
    --query "Functions[?FunctionName=='${POST_FUNCTION_NAME}'].FunctionArn" --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

# Create the API Gateway REST API
echo "Creating the API Gateway REST API..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway create-rest-api \
    --region "${REGION}" \
    --name "${API_NAME}"
echo ${GENERIC_SUCCESS_LOG}

# Retrieve the API ID for the created REST API
echo "Retrieving the API ID for the created REST API..."
API_ID=$(execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway get-rest-apis \
    --query "items[?name=='${API_NAME}'].id" --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

# Get the parent resource ID (the root resource)
echo "Retrieving the parent resource ID (root resource)..."
PARENT_RESOURCE_ID=$(execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway get-resources \
    --rest-api-id "${API_ID}" \
    --query 'items[?path==`/`].id' --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

# Create a new resource under the root resource ("/items")
echo "Creating a new resource under the root resource (\"/items\")..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway create-resource \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --parent-id "${PARENT_RESOURCE_ID}" \
    --path-part items
echo ${GENERIC_SUCCESS_LOG}

# Retrieve the resource ID for the newly created "/items" resource
echo "Retrieving the resource ID for the newly created \"/items\" resource..."
RESOURCE_ID_ALL=$(execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway get-resources \
    --rest-api-id "${API_ID}" \
    --query 'items[?path==`/items`].id' --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

# Define the GET method for the "/items" resource
echo "Defining the GET method for the \"/items\" resource..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-method \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID_ALL}" \
    --http-method GET \
    --authorization-type NONE
echo ${GENERIC_SUCCESS_LOG}

# Define the integration for the GET method
echo "Defining the integration for the GET method..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-integration \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID_ALL}" \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_GET}/invocations \
    --passthrough-behavior WHEN_NO_MATCH
echo ${GENERIC_SUCCESS_LOG}

# Create a resource for individual items ("/items/{itemId}")
echo "Creating a resource for individual items (\"/items/{itemId}\")..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway create-resource \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --parent-id "${RESOURCE_ID_ALL}" \
    --path-part "{itemId}"
echo ${GENERIC_SUCCESS_LOG}

# Retrieve the resource ID for the "/items/{itemId}" resource
echo "Retrieving the resource ID for the \"/items/{itemId}\" resource..."
RESOURCE_ID=$(execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway get-resources \
    --rest-api-id "${API_ID}" \
    --query 'items[?path==`/items/{itemId}`].id' --output text --region "${REGION}")
echo ${GENERIC_SUCCESS_LOG}

# Define the GET method for the "/items/{itemId}" resource
echo "Defining the GET method for the \"/items/{itemId}\" resource..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-method \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID}" \
    --http-method GET \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type NONE
echo ${GENERIC_SUCCESS_LOG}

# Define the integration for the GET method of an individual item
echo "Defining the integration for the GET method of an individual item..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-integration \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID}" \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_GET}/invocations \
    --passthrough-behavior WHEN_NO_MATCH
echo ${GENERIC_SUCCESS_LOG}

# Define the PUT method for the "/items/{itemId}" resource
echo "Defining the PUT method for the \"/items/{itemId}\" resource..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-method \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID}" \
    --http-method PUT \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type NONE
echo ${GENERIC_SUCCESS_LOG}

# Define the integration for the PUT method
echo "Defining the integration for the PUT method..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-integration \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID}" \
    --http-method PUT \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_PUT}/invocations \
    --passthrough-behavior WHEN_NO_MATCH
echo ${GENERIC_SUCCESS_LOG}

# Define the DELETE method for the "/items/{itemId}" resource
echo "Defining the DELETE method for the \"/items/{itemId}\" resource..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-method \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID}" \
    --http-method DELETE \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type NONE
echo ${GENERIC_SUCCESS_LOG}

# Define the integration for the DELETE method
echo "Defining the integration for the DELETE method..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-integration \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID}" \
    --http-method DELETE \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_DELETE}/invocations \
    --passthrough-behavior WHEN_NO_MATCH
echo ${GENERIC_SUCCESS_LOG}

# Define the POST method for the "/items" resource
echo "Defining the POST method for the \"/items\" resource..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-method \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID_ALL}" \
    --http-method POST \
    --authorization-type NONE
echo ${GENERIC_SUCCESS_LOG}

# Define the integration for the POST method
echo "Defining the integration for the POST method..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway put-integration \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --resource-id "${RESOURCE_ID_ALL}" \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_POST}/invocations \
    --passthrough-behavior WHEN_NO_MATCH
echo ${GENERIC_SUCCESS_LOG}

# Create a deployment for the API
echo "Creating a deployment for the API..."
execute aws --endpoint-url="${BASE_ENDPOINT}" apigateway create-deployment \
    --region "${REGION}" \
    --rest-api-id "${API_ID}" \
    --stage-name "${STAGE}"
echo ${GENERIC_SUCCESS_LOG}

# Define the endpoint for accessing the API
ENDPOINT="${BASE_ENDPOINT}/restapis/${API_ID}/${STAGE}/_user_request_/items"

# Save the endpoint to a local environment file
echo "Saving the API endpoint to the local environment file..."
echo "LOCAL_API_ENDPOINT=${ENDPOINT}" > .local.env
echo ${GENERIC_SUCCESS_LOG}

# Output the API endpoint
echo "API available at: ${ENDPOINT}"

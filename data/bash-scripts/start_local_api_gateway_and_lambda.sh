#!/bin/sh

# Base endpoint for the local AWS environment
BASE_ENDPOINT=http://localhost:4566

# API configuration parameters
API_NAME=items_crud              # Name of the API
ROUTE_NAME=items                 # Route for the API
STAGE=test                       # Deployment stage of the API
REGION=us-east-1                 # AWS region for deployment
LAMBDA_ROLE=arn:aws:iam::123456789012:role/lambda-role  # IAM role for Lambda functions

# Function names for different CRUD operations
GET_FUNCTION_NAME=test_items_get_function
PUT_FUNCTION_NAME=test_items_put_function
DELETE_FUNCTION_NAME=test_items_delete_function
POST_FUNCTION_NAME=test_items_post_function

# Function to handle failures and exit the script
function fail() {
    echo $2    # Print the error message
    exit $1    # Exit the script with the specified error code
}

## https://docs.localstack.cloud/user-guide/aws/lambda/

# Create the GET Lambda function
aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${GET_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

# Check if the function creation was successful
[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (GET)"

# Create the PUT Lambda function
aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${PUT_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

# Check if the function creation was successful
[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (PUT)"

# Create the DELETE Lambda function
aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${DELETE_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

# Check if the function creation was successful
[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (DELETE)"

# Create the POST Lambda function
aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${POST_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

# Check if the function creation was successful
[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (POST)"

# Retrieve the ARNs for the created Lambda functions
LAMBDA_ARN_GET=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${GET_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

LAMBDA_ARN_PUT=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${PUT_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

LAMBDA_ARN_DELETE=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${DELETE_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

LAMBDA_ARN_POST=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${POST_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

## https://docs.localstack.cloud/user-guide/aws/apigateway/

# Create the API Gateway REST API
aws --endpoint-url=${BASE_ENDPOINT} apigateway create-rest-api \
    --region ${REGION} \
    --name ${API_NAME}

# Check if the API creation was successful
[ $? == 0 ] || fail 2 "Failed: AWS / apigateway / create-rest-api"

# Retrieve the API ID for the created REST API
API_ID=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-rest-apis \
    --query "items[?name==\`${API_NAME}\`].id" --output text --region ${REGION})

# Get the parent resource ID (the root resource)
PARENT_RESOURCE_ID=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/`].id' --output text --region ${REGION})

# Create a new resource under the root resource ("/items")
aws --endpoint-url=${BASE_ENDPOINT} apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${PARENT_RESOURCE_ID} \
    --path-part "items"

# Retrieve the resource ID for the newly created "/items" resource
RESOURCE_ID_ALL=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/items`].id' --output text --region ${REGION})

# Define the GET method for the "/items" resource
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method GET \
    --authorization-type "NONE"

# Define the integration for the GET method
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_GET}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

# Check if the integration was successful
[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (GET ALL)"

# Create a resource for individual items ("/items/{itemId}")
aws --endpoint-url=${BASE_ENDPOINT} apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${RESOURCE_ID_ALL} \
    --path-part "{itemId}"

# Retrieve the resource ID for the "/items/{itemId}" resource
RESOURCE_ID=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/items/{itemId}`].id' --output text --region ${REGION})

# Define the GET method for the "/items/{itemId}" resource
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type "NONE"

# Check if the GET method creation was successful
[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (GET ITEM)"

# Define the integration for the GET method of an individual item
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_GET}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

# Check if the integration for the GET method was successful
[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (GET ITEM)"

# Define the PUT method for the "/items/{itemId}" resource
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method PUT \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type "NONE"

# Check if the PUT method creation was successful
[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (PUT ITEM)"

# Define the integration for the PUT method
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method PUT \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_PUT}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

# Check if the integration for the PUT method was successful
[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (PUT ITEM)"

# Define the DELETE method for the "/items/{itemId}" resource
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method DELETE \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type "NONE"

# Check if the DELETE method creation was successful
[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (DELETE ITEM)"

# Define the integration for the DELETE method
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method DELETE \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_DELETE}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

# Check if the integration for the DELETE method was successful
[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (DELETE ITEM)"

# Define the POST method for the "/items" resource
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method POST \
    --authorization-type "NONE"

# Check if the POST method creation was successful
[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (POST ITEMS)"

# Define the integration for the POST method
aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_POST}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

# Check if the integration for the POST method was successful
[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (POST ITEMS)"

# Create a deployment for the API
aws --endpoint-url=${BASE_ENDPOINT} apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE}

# Check if the deployment was successful
[ $? == 0 ] || fail 6 "Failed: AWS / apigateway / create-deployment"

# Define the endpoint for accessing the API
ENDPOINT=${BASE_ENDPOINT}/restapis/${API_ID}/${STAGE}/_user_request_/items

# Save the endpoint to a local environment file
echo "LOCAL_API_ENDPOINT=${ENDPOINT}" >> .local.env

# Output the API endpoint
echo "API available at: ${ENDPOINT}"

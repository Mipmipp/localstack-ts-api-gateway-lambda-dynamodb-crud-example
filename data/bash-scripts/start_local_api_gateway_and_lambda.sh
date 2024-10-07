#!/bin/sh

BASE_ENDPOINT=http://localhost:4566
API_NAME=items_crud
ROUTE_NAME=items
STAGE=test
REGION=us-east-1
LAMBDA_ROLE=arn:aws:iam::123456789012:role/lambda-role

GET_FUNCTION_NAME=test_items_get_function
PUT_FUNCTION_NAME=test_items_put_function
DELETE_FUNCTION_NAME=test_items_delete_function
POST_FUNCTION_NAME=test_items_post_function

function fail() {
    echo $2
    exit $1
}

aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${GET_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (GET)"

aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${PUT_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (PUT)"

aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${DELETE_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (DELETE)"

aws --endpoint-url=${BASE_ENDPOINT} lambda create-function \
    --region ${REGION} \
    --function-name ${POST_FUNCTION_NAME} \
    --runtime nodejs20.x \
    --handler index.handler \
    --memory-size 128 \
    --zip-file fileb://C:/Users/CBA/localstack-ts-api-gateway-lambda-dynamodb-crud-example/dist/index.zip \
    --role ${LAMBDA_ROLE}

[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function (POST)"

LAMBDA_ARN_GET=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${GET_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

LAMBDA_ARN_PUT=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${PUT_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

LAMBDA_ARN_DELETE=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${DELETE_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

LAMBDA_ARN_POST=$(aws --endpoint-url=${BASE_ENDPOINT} lambda list-functions \
    --query "Functions[?FunctionName==\`${POST_FUNCTION_NAME}\`].FunctionArn" --output text --region ${REGION})

aws --endpoint-url=${BASE_ENDPOINT} apigateway create-rest-api \
    --region ${REGION} \
    --name ${API_NAME}

[ $? == 0 ] || fail 2 "Failed: AWS / apigateway / create-rest-api"

API_ID=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-rest-apis \
    --query "items[?name==\`${API_NAME}\`].id" --output text --region ${REGION})

PARENT_RESOURCE_ID=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/`].id' --output text --region ${REGION})

aws --endpoint-url=${BASE_ENDPOINT} apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${PARENT_RESOURCE_ID} \
    --path-part "items"

RESOURCE_ID_ALL=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/items`].id' --output text --region ${REGION})

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method GET \
    --authorization-type "NONE"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_GET}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (GET ALL)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${RESOURCE_ID_ALL} \
    --path-part "{itemId}"

RESOURCE_ID=$(aws --endpoint-url=${BASE_ENDPOINT} apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/items/{itemId}`].id' --output text --region ${REGION})

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type "NONE"

[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (GET ITEM)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_GET}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (GET ITEM)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method PUT \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type "NONE"

[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (PUT ITEM)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method PUT \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_PUT}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (PUT ITEM)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method DELETE \
    --request-parameters "method.request.path.itemId=true" \
    --authorization-type "NONE"

[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (DELETE ITEM)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method DELETE \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_DELETE}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (DELETE ITEM)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method POST \
    --authorization-type "NONE"

[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method (POST ITEMS)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID_ALL} \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN_POST}/invocations \
    --passthrough-behavior WHEN_NO_MATCH

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration (POST ITEMS)"

aws --endpoint-url=${BASE_ENDPOINT} apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE}

[ $? == 0 ] || fail 6 "Failed: AWS / apigateway / create-deployment"

ENDPOINT=${BASE_ENDPOINT}/restapis/${API_ID}/${STAGE}/_user_request_/items

echo "API_ID=${API_ID}" >> .local.env

echo "API available at: ${ENDPOINT}"

#!/bin/sh

aws dynamodb create-table \
    --table-name items \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:4566

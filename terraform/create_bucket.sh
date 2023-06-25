#!/bin/bash

AWS_REGION="us-east-1"
AWS_BUCKET_NAME="terraform-state-for-telegram-bot-serverless"
AWS_DYNAMO_DB_TABLE_NAME="terraform-state-for-telegram-bot-serverless-locking"


aws s3api create-bucket --bucket $AWS_BUCKET_NAME --region $AWS_REGION --no-cli-pager --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api put-bucket-versioning --bucket $AWS_BUCKET_NAME --versioning-configuration Status=Enabled --no-cli-pager
aws s3api put-bucket-encryption --bucket $AWS_BUCKET_NAME --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' --no-cli-pager

aws dynamodb create-table --table-name $AWS_DYNAMO_DB_TABLE_NAME --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --tags Key=Name,Value="terraform state dynamo table" Key=CreatedBy,Value="AWS CLI" Key=Region,Value=$AWS_REGION --no-cli-pager

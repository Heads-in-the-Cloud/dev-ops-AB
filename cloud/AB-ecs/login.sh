#!/bin/sh
export AWS_REGION='us-west-2'
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

#!/bin/sh

# Login
export AWS_REGION='us-west-2'
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

export ECR_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# TODO: retrieve from terraform
export DOMAIN=ecs.austin.hitwc.link
export VPC_ID=vpc-0f3dce67ace642302
export DB_URL=$(cat ../secrets/mysql_url.txt)
export ALB_ID=AB-ecs

export REVERSE_PROXY_IMAGE=$ECR_URI/ab-api-gateway:latest
export FLIGHTS_IMAGE=$ECR_URI/ab-flights-microservice:latest
export USERS_IMAGE=$ECR_URI/ab-users-microservice:latest
export BOOKINGS_IMAGE=$ECR_URI/ab-bookings-microservice:latest

# TODO: retrieve from aws-cli secretsmanager
export FLIGHTS_DB_USERNAME=$(cat ../secrets/mysql_username.txt)
export FLIGHTS_DB_PASSWORD=$(cat ../secrets/mysql_password.txt)
export USERS_DB_USERNAME=$(cat ../secrets/mysql_username.txt)
export USERS_DB_PASSWORD=$(cat ../secrets/mysql_password.txt)
export BOOKINGS_DB_USERNAME=$(cat ../secrets/mysql_username.txt)
export BOOKINGS_DB_PASSWORD=$(cat ../secrets/mysql_password.txt)

export JWT_SECRET=$(cat ../secrets/jwt_secret.txt)

docker compose $@

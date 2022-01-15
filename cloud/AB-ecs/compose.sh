#!/bin/sh

export DOMAIN=ecs.austin.hitwc.link
export VPC_ID=vpc-0f3dce67ace642302

export API_GATEWAY_REGISTRY_URI=026390315914.dkr.ecr.us-west-2.amazonaws.com/ab-api-gateway
export FLIGHTS_REGISTRY_URI=026390315914.dkr.ecr.us-west-2.amazonaws.com/ab-flights-microservice
export USERS_REGISTRY_URI=026390315914.dkr.ecr.us-west-2.amazonaws.com/ab-users-microservice
export BOOKINGS_REGISTRY_URI=026390315914.dkr.ecr.us-west-2.amazonaws.com/ab-bookings-microservice

export API_GATEWAY_TAG=latest
export FLIGHTS_TAG=latest
export USERS_TAG=latest
export BOOKINGS_TAG=latest

export DB_URL=$(cat ../secrets/mysql_url.txt)
export DB_USERNAME=$(cat ../secrets/mysql_username.txt)
export DB_PASSWORD=$(cat ../secrets/mysql_password.txt)
export JWT_SECRET=$(cat ../secrets/jwt_secret.txt)

docker compose $@

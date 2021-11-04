#!/bin/sh
host_ip=127.0.0.1
docker run \
  --rm \
  --name users-producer \
  -e "API_HOST=$host_ip:8090" \
  --net host \
  austinbaugh/utopia-users-producer:latest
docker run \
  --rm \
  --name flights-producer \
  -e "API_HOST=$host_ip:8080" \
  --net host \
  austinbaugh/utopia-flights-producer:latest
docker run \
  --rm \
  --name bookings-producer \
  -e "API_HOST=$host_ip:8100" \
  --net host \
  austinbaugh/utopia-bookings-producer:latest

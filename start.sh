#!/usr/bin/env bash

echo "Build the Docker images"

echo "Probe Dock Sensu image"
docker build -t probedock/sensu-server images/sensu-server

echo "Probe Dock Sensu Uchiwa image"
docker build -t probedock/sensu-uchiwa images/sensu-uchiwa

echo "Starting Sensu"
docker-compose -f docker-compose-sensu.yml -p sensu up -d sensu-uchiwa

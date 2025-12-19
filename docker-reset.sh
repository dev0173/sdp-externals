#!/bin/bash
# Reset the docker environment by stopping and deleting the containers, and deleting the volumes

set -euo pipefail

docker compose down

docker volume rm \
  sdp-externals_postgres-data \
  sdp-externals_kafka-data \
  sdp-externals_mailpit-data \
  sdp-externals_opensearch-data 
  
echo "Reset complete. Don't forget to 'docker compose up -d' if you want the containers back again!"


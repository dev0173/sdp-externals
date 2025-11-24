#!/bin/bash
# Reset the docker environment by stopping and deleting the containers, and deleting the volumes

set -euo pipefail

docker compose down

docker volume rm \
  sdp-externals_postgres-data \
  sdp-externals_kafka-data \
  sdp-externals_mailpit-data \
  sdp-externals_opensearch-data \
  sdp-externals_kafka-data-secrets \
  sdp-externals_kafka-init \
  sdp-externals_kafka-shared-config


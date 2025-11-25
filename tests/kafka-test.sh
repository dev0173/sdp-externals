#!/usr/bin/env bash
set -euo pipefail

if ! command -v kcat >/dev/null 2>&1
then
    echo "kcat could not be found. Is it installed?"
    exit 1
fi

source ../.env

echo "Connecting to Kafka with kcat using [${KAFKA_KEYCLOAK_USER}] credentials..."
kcat -b localhost:9095 -X security.protocol=SASL_PLAINTEXT -X sasl.mechanism=SCRAM-SHA-512 \
  -X sasl.username=${KAFKA_KEYCLOAK_USER} -X sasl.password=${KAFKA_KEYCLOAK_PASSWORD} -L
echo "rc=$?"

echo "Connecting to Kafka with kcat using [${KAFKA_DM_USER}] credentials..."
kcat -b localhost:9095 -X security.protocol=SASL_PLAINTEXT -X sasl.mechanism=SCRAM-SHA-512 \
  -X sasl.username=${KAFKA_DM_USER} -X sasl.password=${KAFKA_DM_PASSWORD} -L
echo "rc=$?"

#!/usr/bin/env bash
set -euo pipefail

# Load environment variables from .env file
source .env

# Set the namespace, defaulting to 'semarchy-sdp' if not set
NAMESPACE=($K8S_NAMESPACE:-semarchy-sdp}

# List all secrets in the specified namespace and decode their data
kubectl get secrets -n "$NAMESPACE" -o json \
  | jq -r '.items[] | "\(.metadata.name):", (.data // {} | to_entries[] | "  \(.key)=\(.value | @base64d)")'

  
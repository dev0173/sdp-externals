#!/usr/bin/env bash
set -euo pipefail

# Load secrets from .env file
source .env

# Set the namespace (default to semarchy-sdp if not set)
K8S_NAMESPACE=${K8S_NAMESPACE:-semarchy-sdp}

# List all secrets in the specified namespace and decode their data
kubectl get secrets -n "$K8S_NAMESPACE" -o json \
  | jq -r '.items[] | "\(.metadata.name):", (.data // {} | to_entries[] | "  \(.key)=\(.value | @base64d)")'

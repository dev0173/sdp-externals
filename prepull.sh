#!/usr/bin/env bash
#set -euo pipefail

# Pull all images names in the Helm chart into minikube's Docker daemon

STARTTIME=$(date +%s)
RELEASE_NAME="sdp"
CHART_VERSION="1.0.0"
CHART_PATH="oci://registry.na.semarchy.net/semarchy-release/semarchy-data-platform"
VALUES_FILE="${1:-values.yaml}"
NAMESPACE="semarchy-sdp"

# Check that the values file exists

if [ ! -f "$VALUES_FILE" ]; then
  echo "Values file ($VALUES_FILE) not found!"
  exit 1
fi

# Point Docker CLI at minikube's Docker daemon
echo "[*] Pointing Docker to minikube daemon..."
eval "$(minikube docker-env)"

# Render Helm templates locally
echo "[*] Rendering Helm chart version $CHART_VERSION ..."
helm template "$RELEASE_NAME" "$CHART_PATH" --version "$CHART_VERSION" --values "$VALUES_FILE" > /tmp/rendered.yaml
if [ $? -ne 0 ]; then 
  echo "helm command failed"; 
  exit 1
fi

# Extract unique images (requires yq v4)
echo "[*] Extracting image list ..."
yq '.. | .image? | select(.)' /tmp/rendered.yaml | grep "^[^-]" | sort -u > /tmp/images.txt

echo "[*] Images to pull:"
cat /tmp/images.txt

# Pull each image into minikube's Docker daemon
echo "[*] Pulling images into minikube..."
cat /tmp/images.txt | xargs -n1 docker pull

echo "[*] Done. You can now run:"
echo "  helm upgrade --install $RELEASE_NAME --namespace $NAMESPACE \\"
echo "    $CHART_PATH \\"
echo "    --version $CHART_VERSION --values $VALUES_FILE --debug --timeout 1h"

ENDTIME=$(date +%s)
echo "It took $((ENDTIME - STARTTIME)) seconds to execute this task"

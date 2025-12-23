#!/usr/bin/env bash
#set -euo pipefail

# Pull all images names in the Helm chart into minikube's Docker daemon

RELEASE_NAME="beta5"
CHART_VERSION="1.0.0-beta.5"
CHART_PATH="oci://registry.na.semarchy.net/semarchy-release/semarchy-data-platform"
VALUES_FILE="${1:-values.yaml}"
NAMESPACE="semarchy-sdp"

# 1. Point Docker CLI at minikube's Docker daemon
echo "[*] Pointing Docker to minikube daemon..."
eval "$(minikube docker-env)"

# 2. Render Helm templates locally
echo "[*] Rendering Helm chart version $CHART_VERSION ..."
helm template "$RELEASE_NAME" "$CHART_PATH" --version "$CHART_VERSION" --values "../$VALUES_FILE" > /tmp/rendered.yaml

# 3. Extract unique images (requires yq v4)
echo "[*] Extracting image list ..."
yq '.. | .image? | select(.)' /tmp/rendered.yaml | grep "^[^-]" | sort -u > /tmp/images.txt

echo "[*] Images to pull:"
cat /tmp/images.txt

# 4. Pull each image into minikube's Docker daemon
echo "[*] Pulling images into minikube..."
cat /tmp/images.txt | xargs -n1 docker pull

echo "[*] Done. You can now run:"
echo "  helm upgrade --install $RELEASE_NAME --namespace $NAMESPACE \\"
echo "    $CHART_PATH \\"
echo "    --version $CHART_VERSION --values $VALUES_FILE --debug --timeout 1h"


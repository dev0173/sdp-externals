#!/usr/bin/env bash
#set -euo pipefail

# Build a list of the image names in the Helm chart

RELEASE_NAME="beta5"
CHART_PATH="oci://registry.na.semarchy.net/semarchy-release/semarchy-data-platform"
CHART_VERSION="1.0.0-beta.5"
VALUES_FILE="values.yaml"
NAMESPACE="semarchy-sdp"

# 1. Render Helm templates locally
echo "[*] Rendering Helm chart version $CHART_VERSION ..."
helm template "$RELEASE_NAME" "$CHART_PATH" --version "$CHART_VERSION" --values "$VALUES_FILE" > /tmp/rendered.yaml

# 2. Extract unique images (requires yq v4)
echo "[*] Extracting image list ..."
yq '.. | .image? | select(.)' /tmp/rendered.yaml | grep "^[^-]" | sort -u > /tmp/images.txt

echo "# Pull all required images for chart version $CHART_VERSION" > imgpull-$RELEASE_NAME.sh
cat /tmp/images.txt | xargs -n1 echo docker pull >> imgpull-$RELEASE_NAME.sh

#!/usr/bin/env bash
set -euo pipefail


OPENSEARCH_URL="${OPENSEARCH_URL:-http://opensearch:9200}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:?set ADMIN_PASS}"
SECURITY_ROLE_NAME=${SECURITY_ROLE_NAME:-semarchy-data-platform}
INTERNAL_USER="${INTERNAL_USER:-semarchy-data-platform}"
INTERNAL_USER_PASS="${INTERNAL_USER_PASS:?set INTERNAL_USER_PASS}"

# Wait for Security plugin to report UP (no auth required)
echo "Waiting for OpenSearch on [${OPENSEARCH_URL}] ..."
for i in $(seq 1 120); do
  status="$(curl -sS "$OPENSEARCH_URL/_plugins/_security/health" | tr -d ' \n' | sed 's/.*"status":"\([^"]*\)".*/\1/')"
  [ "$status" = "UP" ] && break
  echo "Retrying... "
  sleep 2
done

# Create/replace security role 
echo "Creating security role [${SECURITY_ROLE_NAME}] : "
curl -sS -X PUT "$OPENSEARCH_URL/_plugins/_security/api/roles/${SECURITY_ROLE_NAME}" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d @/init/role-semarchy-data-platform.json
echo 

# Create/replace an internal user 
echo "Creating internal user [${INTERNAL_USER}] : "
curl -sS -X PUT "$OPENSEARCH_URL/_plugins/_security/api/internalusers/${INTERNAL_USER}" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d "{
        \"password\": \"${INTERNAL_USER_PASS}\",
        \"backend_roles\": [
            \"${SECURITY_ROLE_NAME}\"
          ],
        \"attributes\": { 
          \"env\": \"dev\" 
          }
      }"
echo 

# Map/re-map the role to the user
echo "Mapping security role [${SECURITY_ROLE_NAME}] to user [${INTERNAL_USER}] : "
curl -sS -X PUT "$OPENSEARCH_URL/_plugins/_security/api/rolesmapping/${SECURITY_ROLE_NAME}" \
  -u "$ADMIN_USER:$ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d "{
        \"users\": [\"${INTERNAL_USER}\"] 
      }"
echo

echo "Script complete"
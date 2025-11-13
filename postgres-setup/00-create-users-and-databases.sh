#!/bin/bash
set -euo pipefail

psql --variable=ON_ERROR_STOP=1 --username="${POSTGRES_USER}" --dbname="${POSTGRES_DB}" <<-EOSQL
  CREATE ROLE "keycloak" WITH LOGIN PASSWORD '${SDP_KEYCLOAK_PASSWORD}';
  CREATE DATABASE "keycloak" WITH ENCODING 'UTF8' OWNER 'keycloak' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0 CONNECTION LIMIT -1;
  GRANT ALL PRIVILEGES ON DATABASE "keycloak" TO "keycloak";
  CREATE DATABASE "selfhosted-dm" WITH ENCODING 'UTF8';
EOSQL

echo "Script terminated with rc=$?"

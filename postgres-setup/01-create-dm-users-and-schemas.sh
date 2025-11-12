#!/usr/bin/env bash
set -euo pipefail

psql --variable=ON_ERROR_STOP=1 --username="${POSTGRES_USER}" --dbname="selfhosted-dm" <<-EOSQL

  CREATE USER "selfhosted-dm-repo-user" WITH PASSWORD '${SDP_DM_USER_PASSWORD}';
  CREATE SCHEMA "selfhosted-dm-repo-user" AUTHORIZATION "selfhosted-dm-repo-user";
  GRANT CREATE ON DATABASE "selfhosted-dm" TO "selfhosted-dm-repo-user";

  CREATE SCHEMA extensions AUTHORIZATION "selfhosted-dm-repo-user";
  GRANT USAGE ON SCHEMA extensions TO PUBLIC;
  ALTER DEFAULT PRIVILEGES IN SCHEMA extensions GRANT EXECUTE ON FUNCTIONS TO PUBLIC;
  ALTER DATABASE "selfhosted-dm" SET search_path TO "\$user",public,extensions;
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp" with schema extensions;
  CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" with schema extensions;

  CREATE USER "selfhosted-dm-repo-user-ro" WITH PASSWORD '${SDP_DM_USER_RO_PASSWORD}'; 
  GRANT CONNECT ON DATABASE "selfhosted-dm" to "selfhosted-dm-repo-user-ro";
  ALTER ROLE "selfhosted-dm-repo-user-ro" SET search_path TO "\$user","selfhosted-dm-repo-user",public,extensions;
  GRANT USAGE ON SCHEMA "selfhosted-dm-repo-user" TO "selfhosted-dm-repo-user-ro";

  CREATE USER "datasource-schema-1" WITH PASSWORD '${SDP_DM_DATASOURCE_1_PASSWORD}'; 
  CREATE SCHEMA "datasource-schema-1" AUTHORIZATION "datasource-schema-1";
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "datasource-schema-1" TO "datasource-schema-1";

  CREATE USER "datasource-schema-2" WITH PASSWORD '${SDP_DM_DATASOURCE_2_PASSWORD}'; 
  CREATE SCHEMA "datasource-schema-2" AUTHORIZATION "datasource-schema-2";
  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "datasource-schema-2" TO "datasource-schema-2";

EOSQL

echo "Script terminated with rc=$?"

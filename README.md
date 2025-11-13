## Docker setup of external systems required by SDP

Rename `.env-example` to `.env` and edit the passwords inside it before running `docker compose up -d`. Do not commit your `.env` to git!

The `kube-reset-secrets.sh` script will create/recreate the Kubernetes secrets using values from `.env`.

Rename `values-example.yaml` to `values.yaml` and update the license key, email and name fields. Do not commi your `values.yaml` to git!

## Docker setup of external systems required by SDP

First task:
- Copy `.env-example` to `.env` and change <YOUR_VALUE> to something better wherever you see it. 
- Copy `.env-harbor-example` to `.env-harbor` and add your Harbor Registry credentials as supplied by Semarchy. 
- Copy `values-example.yaml` to `values.yaml` and update the license key, email and name fields. 

*Note:* Do not commit your `.env`, `.env-harbor` or `values.yaml` files to git because the repository is public!

## Startup
- Start the containers with `docker compose up -d`. On first execution this will take some time because it will download required images, and some containers will preform one-off setup procedures.
- Create the Kubernetes secrets by running the `kube-reset-secrets.sh` script. You may need to run `minikube start` first.

## Cleardown/reset
To clear down the system and delete all persisted data:
- Run `docker compose down` to stop and delete the containers
- Run `docker volume rm sdp-externals_postgres-data sdp-externals_kafka-data sdp-externals_mailpit-data sdp-externals_opensearch-data` to 
delete all persisted data

Follow the startup instructions to recreate the containers and secrets.

## Diagnostic tools
There are a few support scripts that may help diagnose problems in the system
- `list-secrets.sh` will query Kubernetes and list the secrets contained in the [semarchy-sdp] namespace. 
- `poddetails.sh` will create a folder structure containing logs and describe file for each pod running in Kubernetes. After running
this script check for a folder called `pod_details_<yyyymmdd>_<hhmmss>`.
- `smtp-test.sh` will send two test emails to the SMTP server. These should be visible in the UI at https://localhost:8025
- A basic Postgres web UI is at https://localhost:8090
- A basic Kafka web UI is at https://localhost:8080 
- OpenSearch dashboards are available at https://localhost:5601

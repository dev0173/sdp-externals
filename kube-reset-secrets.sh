#!/bin/bash
# Reset the Kubernetes namespace and recreate necessary secrets for Semarchy SDP

set -euo pipefail

# Exit if kubernetes is not available
if ! kubectl version --request-timeout=5s >/dev/null 2>&1; then
    echo "Cannot reach the Kubernetes cluster. Is minikube started?" >&2
    exit 1
fi

# Load secrets from .env files
source .env
source .env-harbor

# Set the namespace (default to semarchy-sdp if not set)
K8S_NAMESPACE=${K8S_NAMESPACE:-semarchy-sdp}

# Delete the existing namespace
kubectl delete namespaces ${K8S_NAMESPACE} --ignore-not-found=true

# Create a namespace:
kubectl create namespace ${K8S_NAMESPACE}

# Add a secret for Semarchy’s Harbor docker registry. Uses .env-harbor for credentials.
kubectl create secret docker-registry semarchy-harbor \
    --docker-server=registry.na.semarchy.net \
    --docker-username="${K8S_HARBOR_USER}" \
    --docker-password="${K8S_HARBOR_PASSWORD}" \
    --namespace="${K8S_NAMESPACE}"

# Add Postgres keycloak secret:
kubectl create secret generic keycloak-postgres \
    --from-literal=port="5432" \
    --from-literal=host="host.docker.internal" \
    --from-literal=username="keycloak" \
    --from-literal=password="${SDP_KEYCLOAK_PASSWORD}" \
    --from-literal=database="keycloak" \
    --namespace="${K8S_NAMESPACE}"

# Add a Postgres DM secret:
kubectl create secret generic dm-postgres \
    --from-literal=database-host="host.docker.internal" \
    --from-literal=database-jdbc-url="jdbc:postgresql://host.docker.internal:5432/selfhosted-dm" \
    --from-literal=database-name="selfhosted-dm" \
    --from-literal=database-port="5432" \
    --from-literal=semarchy-repository-role="selfhosted-dm-repo-user" \
    --from-literal=semarchy-repository-password="${SDP_DM_USER_PASSWORD}" \
    --from-literal=semarchy-repository-ro-role="selfhosted-dm-repo-user-ro" \
    --from-literal=semarchy-repository-ro-password="${SDP_DM_RO_USER_PASSWORD}" \
    --namespace="${K8S_NAMESPACE}"

# Add a secret for data source 1:
kubectl create secret generic dm-postgres-datasource-1 \
    --from-literal=semarchy-role="datasource-schema-1" \
    --from-literal=semarchy-password="datasource-1" \
    --from-literal=database-port="5432" \
    --from-literal=database-name="selfhosted-dm" \
    --from-literal=database-host="host.docker.internal" \
    --from-literal=database-jdbc-url="jdbc:postgresql://host.docker.internal:5432/selfhosted-dm" \
    --namespace="${K8S_NAMESPACE}"

# Add a secret for data source 2:
kubectl create secret generic dm-postgres-datasource-2 \
    --from-literal=semarchy-role="datasource-schema-2" \
    --from-literal=semarchy-password="datasource-2" \
    --from-literal=database-port="5432" \
    --from-literal=database-name="selfhosted-dm" \
    --from-literal=database-host="host.docker.internal" \
    --from-literal=database-jdbc-url="jdbc:postgresql://host.docker.internal:5432/selfhosted-dm" \
    --namespace="${K8S_NAMESPACE}"

# Add a secret for Kafka keycloak:
kubectl create secret generic kafka-keycloak \
    --from-literal=admin-username="keycloak" \
    --from-literal=admin-password="${KAFKA_KEYCLOAK_PASSWORD}" \
    --from-literal=bootstrap-servers="host.docker.internal:9094" \
    --from-literal=sasl-jaas-config="org.apache.kafka.common.security.scram.ScramLoginModule required username=\"keycloak\" password=\"${KAFKA_KEYCLOAK_PASSWORD}\";" \
    --from-literal=security-protocol="SASL_PLAINTEXT" \
    --namespace="${K8S_NAMESPACE}"

# Add a secret for Kafka DM:
kubectl create secret generic dm-kafka \
    --from-literal=bootstrap-servers="host.docker.internal:9094" \
    --from-literal=username="selfhosted-dm" \
    --from-literal=password="${KAFKA_DM_PASSWORD}" \
    --from-literal=sasl-jaas-config="org.apache.kafka.common.security.scram.ScramLoginModule required username=\"selfhosted-dm\" password=\"${KAFKA_DM_PASSWORD}\";" \
    --from-literal=security-protocol="SASL_PLAINTEXT" \
    --from-literal=consumer-group="selfhosted-dm" \
    --namespace="${K8S_NAMESPACE}"

# Add OpenSearch connection secret:
kubectl create secret generic opensearch-provider \
    --from-literal=host="host.docker.internal" \
    --from-literal=url="http://host.docker.internal:9200" \
    --from-literal=port="9200" \
    --from-literal=username="${OPENSEARCH_INTERNAL_USER}" \
    --from-literal=password="${OPENSEARCH_INTERNAL_USER_PASSWORD}" \
    --namespace="${K8S_NAMESPACE}"

# Add SMTP connection secret:
kubectl create secret generic mail-secret \
    --from-literal=smtpUser="sdp@sdp.selfhosted.com" \
    --from-literal=smtpHost="host.docker.internal" \
    --from-literal=smtpPort="1025" \
    --from-literal=smtpStartTls="false" \
    --from-literal=smtpSsl="false" \
    --from-literal=smtpAuth="false" \
    --from-literal=smtpPassword="" \
    --namespace="${K8S_NAMESPACE}"

# List the secrets
kubectl get secrets --namespace="${K8S_NAMESPACE}"

echo "Kubernetes namespace ${K8S_NAMESPACE} has been reset and secrets recreated."

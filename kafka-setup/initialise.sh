set -eu

# Pull values from environment variables (or fail if passwords not set)
KAFKA_URL="${KAFKA_URL:-kafka:9092}"
KAFKA_DM_TOPIC="${KAFKA_DM_TOPIC:-topic-user}"
KAFKA_DM_USER="${KAFKA_DM_USER:-selfhosted-dm}"
KAFKA_DM_PASSWORD="${KAFKA_DM_PASSWORD:?set KAFKA_DM_PASSWORD}"
KAFKA_KEYCLOAK_USER="${KAFKA_KEYCLOAK_USER:-keycloak}"
KAFKA_KEYCLOAK_PASSWORD="${KAFKA_KEYCLOAK_PASSWORD:?set KAFKA_KEYCLOAK_PASSWORD}"

# Make Kafka CLI tools available
KAFKA_BIN="${KAFKA_BIN:-/opt/kafka/bin}"
export PATH="$KAFKA_BIN:$PATH"

echo "===> Waiting for Kafka on [${KAFKA_URL}] ...";
kafka-broker-api-versions.sh --bootstrap-server ${KAFKA_URL} --version;

echo "===> Creating SCRAM users for DM and keycloak";
kafka-configs.sh --bootstrap-server ${KAFKA_URL} --alter --entity-type users --entity-name ${KAFKA_DM_USER} \
  --add-config "SCRAM-SHA-512=[iterations=4096,password=${KAFKA_DM_PASSWORD}]"; 
echo "rc=$?";  
kafka-configs.sh --bootstrap-server ${KAFKA_URL} --alter --entity-type users --entity-name ${KAFKA_KEYCLOAK_USER} \
  --add-config "SCRAM-SHA-512=[iterations=4096,password=${KAFKA_KEYCLOAK_PASSWORD}]";
echo "rc=$?";  

echo "===> Creating topic 'topic-user' with compaction";
kafka-topics.sh --bootstrap-server ${KAFKA_URL} --create --if-not-exists --topic ${KAFKA_DM_TOPIC} \
  --partitions 5 --replication-factor 1 --config segment.ms=20000 --config cleanup.policy=compact;
echo "rc=$?";  

echo "===> Adding ACLs for appuser (produce/consume) and admin (cluster)";
kafka-acls.sh --bootstrap-server ${KAFKA_URL} --add \
  --allow-principal User:${KAFKA_DM_USER} --operation Read --topic ${KAFKA_DM_TOPIC}
echo "rc=$?";  
kafka-acls.sh --bootstrap-server ${KAFKA_URL} --add \
  --allow-principal User:${KAFKA_DM_USER} --operation Read --group ${KAFKA_DM_USER}
echo "rc=$?";  
kafka-acls.sh --bootstrap-server ${KAFKA_URL} --add \
  --allow-principal User:${KAFKA_KEYCLOAK_USER} --operation Write --topic ${KAFKA_DM_TOPIC}
echo "rc=$?";  

# (Optional) Explicit cluster-wide admin perms (admin is also a super-user via env)
kafka-acls.sh --bootstrap-server ${KAFKA_URL} --add \
  --allow-principal User:admin --operation All --cluster;
echo "rc=$?";  

echo "===> Setup complete.";

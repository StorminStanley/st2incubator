#!/bin/bash
set -e

MISTRAL_PATH=$1
DB_TYPE=$2
DB_NAME=$3
DB_USER_NAME=$4
DB_USER_PASS=$5
API_PORT=$6

MISTRAL_CONFIG=${MISTRAL_PATH}/mistral.conf
MISTRAL_LOG_CONFIG=${MISTRAL_PATH}/wf_trace_logging.conf

# Check database type.
if [ "${DB_TYPE}" != "mysql" ] && [ "${DB_TYPE}" != "postgresql" ]; then
    >&2 echo "ERROR: ${DB_TYPE} is an unsupported database type."
    exit 1
fi

# Write mistral configuration file.
echo "Writing mistral configuration to ${MISTRAL_CONFIG}..."

if [ -e "${MISTRAL_CONFIG}" ]; then
  rm -f ${MISTRAL_CONFIG}
fi

touch ${MISTRAL_CONFIG}
cat <<mistral_config >${MISTRAL_CONFIG}
[api]
port=${API_PORT}

[database]
connection=${DB_TYPE}://${DB_USER_NAME}:${DB_USER_PASS}@localhost/${DB_NAME}
max_pool_size=25
max_overflow=50
idle_timeout=30

[pecan]
auth_enable=false
mistral_config

# Write mistral log configuration file.
echo "Writing mistral log configuration to ${MISTRAL_LOG_CONFIG}..."

if [ -e "${MISTRAL_LOG_CONFIG}" ]; then
  rm -f ${MISTRAL_LOG_CONFIG}
fi

cp ${MISTRAL_PATH}/etc/wf_trace_logging.conf.sample ${MISTRAL_LOG_CONFIG}

mkdir -p ${MISTRAL_PATH}/logs
sed -i "s~${MISTRAL_PATH}/logs~/var/log~g" ${MISTRAL_LOG_CONFIG}

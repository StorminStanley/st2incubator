#!/bin/bash
set -e

ST2_LOG_DIR=$1
MISTRAL_LOG_DIR=$2
BACKUP_DIR=$3

if [[ ! -d "${ST2_LOG_DIR}" ]]; then
    >&2 echo "ERROR: ${ST2_LOG_DIR} does not exist."
    exit 1
fi

if [[ ! -d "${MISTRAL_LOG_DIR}" ]]; then
    >&2 echo "ERROR: ${MISTRAL_LOG_DIR} does not exist."
    exit 1
fi

if [[ ! -d "${BACKUP_DIR}" ]]; then
    mkdir -p ${BACKUP_DIR}
fi

# Backup st2 and mistral logs
cp ${ST2_LOG_DIR}/*.log ${BACKUP_DIR}
cp ${MISTRAL_LOG_DIR}/mistral*.log ${BACKUP_DIR} 

# Capture any DB deadlocks
sudo -u postgres psql -c "SELECT ka.query AS blocking, a.query AS blocked FROM pg_catalog.pg_locks bl JOIN pg_catalog.pg_stat_activity a ON a.pid = bl.pid JOIN pg_catalog.pg_locks kl ON kl.transactionid = bl.transactionid AND kl.pid != bl.pid JOIN pg_catalog.pg_stat_activity ka ON ka.pid = kl.pid WHERE NOT bl.GRANTED;" > ${BACKUP_DIR}/psql_deadlocks.log

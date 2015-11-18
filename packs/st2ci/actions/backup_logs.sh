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

cp ${ST2_LOG_DIR}/*.log ${BACKUP_DIR}
cp ${MISTRAL_LOG_DIR}/mistral*.log ${BACKUP_DIR} 

#!/bin/bash
set -e

ST2_EXEC_ID=$1
MISTRAL_REPO=$2
MISTRAL_LOG_DIR=$3
ST2_LOG_DIR=$4
BACKUP_DIR=$5

# Cleanup anything from the backup directory older than a week
find ${BACKUP_DIR}/* -type d -ctime +7 | xargs rm -rf

# Create a new directory for this execution
BACKUP_PATH=${BACKUP_DIR}/${ST2_EXEC_ID}
if [[ ! -d "${BACKUP_PATH}" ]]; then
    mkdir -p ${BACKUP_PATH}
fi

# Backup st2 logs
if [[ -d "${ST2_LOG_DIR}" ]]; then
    echo "Backing up st2 logs..."
    cp ${ST2_LOG_DIR}/*.log ${BACKUP_PATH}
fi

# Backup mistral logs
if [[ -d "${MISTRAL_LOG_DIR}" ]]; then
    echo "Backing up mistral logs..."
    cp ${MISTRAL_LOG_DIR}/mistral*.log ${BACKUP_PATH} 
fi

# Capture any DB deadlocks
echo "Capturing DB logs..."
sudo -u postgres psql -x -c "SELECT ka.query AS blocking, a.query AS blocked FROM pg_catalog.pg_locks bl JOIN pg_catalog.pg_stat_activity a ON a.pid = bl.pid JOIN pg_catalog.pg_locks kl ON kl.transactionid = bl.transactionid AND kl.pid != bl.pid JOIN pg_catalog.pg_stat_activity ka ON ka.pid = kl.pid WHERE NOT bl.GRANTED;" > ${BACKUP_PATH}/psql_deadlocks.log

# Restart services to clear locks so the backup steps below can run.
sudo service mistral stop
sudo service postgresql restart
sudo service mistral start

# Backup the list of WF and task executions
. ${MISTRAL_REPO}/.venv/bin/activate
mistral execution-list > ${BACKUP_PATH}/mistral_execution_list.txt
mistral task-list > ${BACKUP_PATH}/mistral_task_list.txt
deactivate

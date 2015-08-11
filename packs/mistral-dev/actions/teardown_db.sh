#!/bin/bash
set -e

DB_TYPE=$1
DB_NAME=$2
DB_USER_NAME=$3
DB_ROOT_PASS=$4

# Deleting database and user.
echo "Deleting database and user in ${DB_TYPE}..."

if [ "${DB_TYPE}" == "mysql" ]; then
    mysql -uroot -p${DB_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${DB_NAME}"
    mysql -uroot -p${DB_ROOT_PASS} -e "DROP USER '${DB_USER_NAME}'@'%'"
    mysql -uroot -p${DB_ROOT_PASS} -e "FLUSH PRIVILEGES"
elif [ "${DB_TYPE}" == "postgresql" ]; then
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DB_NAME};"
    sudo -u postgres psql -c "DROP USER IF EXISTS ${DB_USER_NAME};"
else
    >&2 echo "ERROR: ${DB_TYPE} is an unsupported database type."
    exit 1
fi

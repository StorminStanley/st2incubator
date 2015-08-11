#!/bin/bash
set -e

REPO=$1

if [[ ! -d "${REPO}" ]]; then
    >&2 echo "ERROR: ${REPO} does not exist."
    exit 1
fi

# Create virtualenv and install requirements.
cd ${REPO}
make requirements

# Remove database if exists.
mongo st2 --eval "db.dropDatabase();"

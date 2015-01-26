#!/bin/bash

# Terminate on error.
set -e

# Setup variables.
ST2_REPO_ROOT=$1
OS_REPO_ROOT=$2
OPT_DIR=/opt/openstack
REALPATH=`realpath ${OPT_DIR}/mistral`

if [[ "${REALPATH}" = "${ST2_REPO_ROOT}/mistral" ]]; then
    REPO="st2"
elif [[ "${REALPATH}" = "${OS_REPO_ROOT}/mistral" ]]; then
    REPO="os"
else
    REPO="Unknown"
fi

echo ""
echo "PATH: ${OPT_DIR}/mistral"
echo "REALPATH: ${REALPATH}"
echo "WHICH: ${REPO}"

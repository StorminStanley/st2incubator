#!/bin/bash

# Terminate on error.
set -e

# Setup variables.
OPT_DIR=/opt/openstack
REALPATH=`realpath ${OPT_DIR}/mistral`
ST2_GIT_REPO="git@github.com:StackStorm/mistral.git"
OS_GIT_REPO="git@github.com:openstack/mistral.git"

cd ${REALPATH}
WORKING_GIT_REPO="Unknown"
REMOTE_ORIGIN_URL=`git config -l | grep remote.origin.url`
if [[ "${REMOTE_ORIGIN_URL}" = "remote.origin.url=${OS_GIT_REPO}" ]]; then
    WORKING_GIT_REMOTE_ORIGIN_URL=${OS_GIT_REPO}
elif [[ "${REMOTE_ORIGIN_URL}" = "remote.origin.url=${ST2_GIT_REPO}" ]]; then
    WORKING_GIT_REMOTE_ORIGIN_URL=${ST2_GIT_REPO}
fi

echo ""
echo "PATH: ${OPT_DIR}/mistral"
echo "REALPATH: ${REALPATH}"
echo "REMOTE ORIGIN: ${WORKING_GIT_REMOTE_ORIGIN_URL}"
echo ""

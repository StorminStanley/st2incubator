#!/bin/bash

# Terminate on error.
set -e

# Setup variables.
ST2_REPO_ROOT=$1
OS_REPO_ROOT=$2
REPO=$3
BRANCH=$4

OPT_DIR=/opt/openstack
WWW_DIR=/var/www

if [[ "${REPO}" = "st2" ]]; then
    SWITCH_TO=${ST2_REPO_ROOT}
else
    SWITCH_TO=${OS_REPO_ROOT}    
fi

echo "ST2_REPO_ROOT: ${ST2_REPO_ROOT}"
echo "OS_REPO_ROOT: ${OS_REPO_ROOT}"
echo "REPO: ${REPO}"
echo "SWITCH_TO: ${SWITCH_TO}"

# Exit if expected paths do not exist.
FOLDERS=(
    "${SWITCH_TO}"
    "${SWITCH_TO}/mistral"
    "${SWITCH_TO}/python-mistralclient"
)

for i in "${FOLDERS[@]}"
do
    if [[ ! -d "${i}" ]]; then
        echo "The path ${i} does not exist."
        exit 1
    fi
done

# Switch the symbolic link for mistral.
if [[ ! -d ${OPT_DIR} ]]; then
    echo "Creating directory ${OPT_DIR}..."
    mkdir -p ${OPT_DIR}
fi

cd ${OPT_DIR}
if [[ -L ${OPT_DIR}/mistral ]]; then
    rm mistral
fi
ln -s ${SWITCH_TO}/mistral mistral

cd ${WWW_DIR}
if [[ -L ${WWW_DIR}/mistral ]]; then
    rm mistral
fi
ln -s ${SWITCH_TO}/mistral mistral

# Reinstall the python-mistralclient.
cd ${SWITCH_TO}/python-mistralclient
python setup.py develop

# Restart the mistral service appropriately
echo ""
IS_SERVICE_RUNNING=`service mistral status | grep running; exit 0`
if [ -z "${IS_SERVICE_RUNNING}" ]; then
    echo "Not restarting mistral. The mistral service was not running."
else
    echo "Restarting mistral service..."
    service mistral restart
fi

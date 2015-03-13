#!/bin/bash

PYTHON=`which python`
REPO=$1
DATE=`date +%s`
CONFIG_DIR=$2
OUTPUT=/tmp/output-$DATE
MISTRAL_DIR=$REPO

touch $OUTPUT

if [[ ! -d "$REPO" ]]
then
  echo "ERROR: repo ${REPO} doesn't exist."
  exit 1
fi

# Mistral isn't a daemon. Fabric doesn't like to bg processes. So
# we use upstart instead.
setup_mistral_upstart()
{
upstart=/etc/init/mistral.conf
if [ -e "$upstart" ]; then
  rm $upstart
fi
touch $upstart
cat <<mistral_upstart >$upstart
description "Mistral Workflow Service"
start on runlevel [2345]
stop on runlevel [016]
respawn
exec ${MISTRAL_DIR}/.venv/bin/python ${MISTRAL_DIR}/mistral/cmd/launch.py --config-file ${CONFIG_DIR}/mistral.conf --log-config-append ${CONFIG_DIR}/wf_trace_logging.conf
mistral_upstart
}

setup_mistral_upstart
rm $OUTPUT

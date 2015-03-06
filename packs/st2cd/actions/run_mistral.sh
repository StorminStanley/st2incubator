#!/bin/bash

PYTHON=`which python`
REPO=$1
DATE=`date +%s`
BRANCH=$2
CONFIG_DIR=$3
OUTPUT=/tmp/output-$DATE

touch $OUTPUT

if [[ ! -d "$REPO" ]]
then
  echo "ERROR: repo ${REPO} doesn't exist."
  exit 1
fi

cd $REPO
$REPO/mistral/.venv/bin/python $REPO/mistral/mistral/cmd/launch.py --config-file ${CONFIG_DIR}/mistral.conf 2>&1 > /tmp/mistral-itests-DATE.log

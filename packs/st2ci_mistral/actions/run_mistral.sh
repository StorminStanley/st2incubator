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

## Check if mistral is already running
netstat -tupln | grep 8989
if [[ $? == 0 ]]
then
    echo "ERROR: Mistral is already running on the box."
    exit 2  # Just exit for now.
fi

## Setup mistral logging
LOG_CONFIG_FILE=$CONFIG_DIR/wf_trace_logging.conf
cp $REPO/etc/wf_trace_logging.conf.sample $LOG_CONFIG_FILE
LOG_FILE=/tmp/mistral-itests-$DATE.log
LOG_TRACE_FILE=/tmp/mistral-trace-itests-$DATE.log
sed -i s:/var/log/mistral.log:$LOG_FILE:g $LOG_CONFIG_FILE
sed -i s:/var/log/mistral_wf_trace.log:$LOG_TRACE_FILE:g $LOG_CONFIG_FILE
sed -i s:INFO:DEBUG:g $LOG_CONFIG_FILE

service mistral start

if [[ $? != 0 ]]
then
  echo "ERROR: Failed to start service - mistral."
  exit 3
fi
exit 0

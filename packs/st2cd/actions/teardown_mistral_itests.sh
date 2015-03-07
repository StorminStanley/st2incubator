#!/bin/bash

MISTRAL_PID=`ps auxww | grep mistral | grep -v grep | awk '{print $2}'`
kill -s TERM $MISTRAL_PID

if [[ $? == 0 ]]
then
    echo "SUCCESS: Killed mistral process with PID ${MISTRAL_PID}"
else
    echo "ERROR: Could not kill mistral process with PID ${MISTRAL_PID}"
    exit 1
fi

#!/bin/bash

REPO=$1
DROP_DBS=$2

if [[ ! -d $REPO ]]
then
    echo "ERROR: $REPO doesn't exist."
    exit 1
fi

# Shutdown st2
cd $REPO
tools/launchdev.sh stop
if [[ $? != 0 ]]
then
    echo "ERROR: Unable to shut down st2."
fi

make distclean
if [[ $? != 0 ]]
then
    echo "ERROR: make distclean failed in st2."
fi

service mistral stop
sleep 10

# Wipe clean dbs
if [ "$DROP_DBS" == "true" ] || [ "$DROP_DBS" == "True" ] || [ "$DROP_DBS" == "TRUE" ]
then
    mongo st2 --eval "db.dropDatabase();"
    if [[ $? != 0 ]]
    then
        echo "ERROR: Unable to drop database 'st2' in mongo."
    fi
fi

# Kill mistral
MISTRAL_PID=`ps auxww | grep mistral | grep launch.py | grep -v grep | awk '{print $2}'`
if [ ! -z "$MISTRAL_PID" ]
then
    echo "MISTRAL_PID: $MISTRAL_PID is still running. Trying to kill."
    kill -s TERM $MISTRAL_PID
fi

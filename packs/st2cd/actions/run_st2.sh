#!/bin/bash

PYTHON=`which python`
REPO=$1
DATE=`date +%s`

if [[ ! -d $REPO ]]
then
    echo "ERROR: $REPO doesn't exist."
    exit 1
fi

cd $REPO
make requirements
if [[ $? != 0 ]]
then
    echo "ERROR: Failed setting up st2 virtualenv."
    exit 2
fi

if [[ ! -f $REPO/tools/launchdev.sh ]]
then
    echo "ERROR: launchdev.sh not found in $REPO/tools/"
    exit 3
fi

echo "DEBUG: Launching st2..."
$REPO/tools/launchdev.sh startclean

exit 0

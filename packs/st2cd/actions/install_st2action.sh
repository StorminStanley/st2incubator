#!/bin/bash

GIT=`which git`
PYTHON=`which python`
REPO=$1
DATE=`date +%s`
BRANCH=$2
OUTPUT=/tmp/git-output-$DATE

if [[ ! -d "$REPO" ]]
then
  echo "ERROR: repo ${REPO} doesn't exist."
  exit 1
fi

cd ${REPO}
OUT=`$GIT checkout ${BRANCH} -q`
if [[ $? == 0 ]]
then
  OUT=`$PYTHON setup.py develop > $OUTPUT`
  if [[ $? == 0 ]]
  then
    echo 'Link to /etc/mistral/st2action?'
  else
    echo 'ERROR: Failed to install st2action.'
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 4
fi

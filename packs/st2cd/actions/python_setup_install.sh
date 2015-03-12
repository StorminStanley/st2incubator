#!/bin/bash

GIT=`which git`
PYTHON=`which python`
REPO=$1
DATE=`date +%s`
BRANCH=$2
OUTPUT=/tmp/setup-py-install-git-output-$DATE

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
    echo "SUCCESS: Installed artifacts from ${REPO}."
    rm ${OUTPUT}
  else
    echo "ERROR: Failed to install artifacts from ${REPO}."
    rm ${OUTPUT}
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 4
fi

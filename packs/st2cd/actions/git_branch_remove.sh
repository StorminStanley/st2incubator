#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
OUTPUT=/tmp/git-output-$DATE

cd ${REPO}
OUT=`$GIT pull origin master -q > $OUTPUT && $GIT checkout ${BRANCH} -q`
if [[ $? == 0 ]]
then
  OUT=`$GIT push origin -q :$BRANCH`
  if [[ $? == 0 ]]
  then
    echo ${BRANCH}
  else
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 1
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 2
fi

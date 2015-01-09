#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
VERSION=$2
BRANCH=v$2
OUTPUT=/tmp/git-output-$DATE

cd ${REPO}
OUT=`$GIT pull origin master -q > $OUTPUT && $GIT branch ${BRANCH} -q && $GIT checkout ${BRANCH} -q`
if [[ $? == 0 ]]
then
  OUT=`$GIT push origin -q $BRANCH`
  if [[ $? == 0 ]]
  then
    echo ${BRANCH}
  else
    cat ${OUTPUT}
    rm ${OUTPUT}
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
fi

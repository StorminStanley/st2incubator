#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2

OUTPUT=/tmp/git-output-$DATE

if [[ ! -d ${REPO} ]]
then
  echo "Cloned repo not found in ${REPO}"
  exit 1
fi

cd ${REPO}
OUT=`$GIT checkout ${BRANCH} -q > ${OUTPUT} && $GIT push origin ${BRANCH} -q > ${OUTPUT}`
if [[ $? == 0 ]]
then
  echo ${BRANCH}
else
  echo "Failed to push branch ${BRANCH} upstream."
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 2
fi

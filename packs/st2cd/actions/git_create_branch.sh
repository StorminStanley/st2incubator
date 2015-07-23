#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
BASE_BRANCH=$3
OUTPUT=/tmp/git-output-$DATE

if [[ ! -d ${REPO} ]]
then
  echo "Cloned repo not found in ${REPO}"
  exit 1
fi

cd ${REPO}
OUT=`$GIT checkout ${BASE_BRANCH} -q > ${OUTPUT} && \
    $GIT pull origin ${BASE_BRANCH} -q >> ${OUTPUT} && \
    $GIT branch ${BRANCH} -q >> ${OUTPUT} && \
    $GIT checkout ${BRANCH} -q >> ${OUTPUT}`
if [[ $? == 0 ]]
then
  echo ${BRANCH}
  exit 0
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 2
fi

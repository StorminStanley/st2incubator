#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
MSG=$3
OUTPUT=/tmp/git-output-$DATE

if [[ ! -d ${REPO} ]]
then
  echo "Cloned repo not found in ${REPO}"
  exit 1
fi

cd ${REPO}
GIT_BRANCH=$(${GIT} symbolic-ref --short -q HEAD)

if [[ ${GIT_BRANCH} != ${BRANCH} ]]
then
  echo "Changes not in specified branch but on a different branch ${GIT_BRANCH}. Aborting."
  exit 2
fi

OUT=`$GIT add -A && $GIT commit -m ${MSG} > ${OUTPUT}`
if [[ $? == 0 ]]
then
  echo "Committed ${MSG} to ${BRANCH}."
  exit 0
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 2
fi

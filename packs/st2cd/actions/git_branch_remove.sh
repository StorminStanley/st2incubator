#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
OUTPUT=/tmp/git-output-$DATE

cd ${REPO}

# There could be a tag with the same name so use complete path.
OUT=`$GIT push origin :refs/heads/$BRANCH  > ${OUTPUT}`
if [[ $? == 0 ]]
then
  echo ${BRANCH}
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 1
fi

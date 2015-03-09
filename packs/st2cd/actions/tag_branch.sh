#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
OUTPUT=/tmp/git-output-$DATE

cd ${REPO}
OUT=`$GIT checkout ${BRANCH} -q && $GIT pull origin ${BRANCH} -q > ${OUTPUT}`
if [[ $? == 0 ]]
then
  NEWTAG=`git describe --tags --abbrev=0 | awk -F '[ .]' '{print $1"."$2"."$3+1}'`
  if [[ $? == 0 ]]
  then
    OUT=`$GIT tag -a ${NEWTAG} -m "Creating tag ${NEWTAG} for branch ${BRANCH}" && $GIT push origin ${NEWTAG} -q`
    if [[ $? == 0 ]]
    then
      echo ${NEWTAG}
    else
      cat ${OUTPUT}
      rm ${OUTPUT}
      exit 1
    fi
  else
    echo 'ERROR: Failed to generate tag'
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 2
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 3
fi

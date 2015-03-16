#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
UPSTREAM=$3
OUTPUT=/tmp/git-output-$DATE

if [[ ! -d "$REPO" ]]
then
  echo "ERROR: repo ${REPO} doesn't exist."
  exit 1
fi

cd ${REPO}
OUT=`$GIT checkout ${BRANCH} -q && $GIT pull origin ${BRANCH} -q > ${OUTPUT}`
if [[ $? == 0 ]]
then
  OUT=`$GIT remote add upstream ${UPSTREAM} > ${OUTPUT}`
  OUT=`$GIT fetch upstream -v -q > ${OUTPUT}`
  if [[ $? == 0 ]]
  then
    OUT=`$GIT merge upstream/${BRANCH} -q > ${OUTPUT}`
    if [[ $? == 0 ]]
    then
      HEAD=`$GIT rev-parse --verify HEAD`
      echo "$HEAD."
      exit 0
    else
      echo "ERROR: Merge of upstream/${BRANCH} into $BRANCH failed."
      exit 2
    fi
  else
    echo 'ERROR: Failed fetching upstream repo ${UPSTREAM}.'
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 3
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 4
fi

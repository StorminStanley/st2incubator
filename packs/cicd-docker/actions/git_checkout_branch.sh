#!/bin/bash

GIT=`which git`
TARGET="${1}"
BRANCH="${2}"


if [[ ! -d $TARGET ]]
then
    echo "${TARGET} doesn't exist."
    exit 1
fi

GITOUTPUT=`cd ${TARGET} && $GIT checkout $BRANCH && cd -`

if [[ $? == 0 ]]
then
  echo $TARGET
else
  echo $GITOUTPUT
  exit 2
fi

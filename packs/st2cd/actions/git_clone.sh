#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
TARGET="${2}_${DATE}_$BASHPID"
BRANCH=$3

if [[ -d $TARGET ]]
then
    echo $TARGET
    exit 0
fi

GITOUTPUT=`$GIT clone -b ${BRANCH} --single-branch $REPO $TARGET`

if [[ $? == 0 ]]
then
  echo $TARGET
else
  echo $GITOUTPUT
  exit 1
fi

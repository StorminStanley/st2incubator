#!/bin/bash

GIT=`which git`
REPO=$1
TARGET="${2}"
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
fi

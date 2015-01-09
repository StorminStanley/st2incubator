#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
TARGET="${2}_${DATE}"

GITOUTPUT=`$GIT clone $REPO $TARGET`

if [[ $? == 0 ]]
then
  echo $TARGET
else
  echo $GITOUTPUT
fi

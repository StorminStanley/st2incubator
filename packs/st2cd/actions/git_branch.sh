#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
VERSION=$2
BRANCH=$3
BASE_BRANCH=$4
FILE="st2common/st2common/__init__.py"
OUTPUT=/tmp/git-output-$DATE

cd ${REPO}
OUT=`$GIT checkout ${BASE_BRANCH} -q > $OUTPUT && $GIT pull origin ${BASE_BRANCH} -q > $OUTPUT && $GIT checkout -b ${BRANCH} -q`
if [[ $? == 0 ]]
then
  VERSIONOUT=`sed -i -e "s/\(__version__ = \).*/\1'${VERSION}'/" ${FILE}`
  if [[ $? == 0 ]]
  then
    OUT=`$GIT add $FILE > $OUTPUT && $GIT commit -aqm "Cutting branch for release - ${VERSION}" > $OUTPUT && $GIT push origin $BRANCH -q > $OUTPUT`
    if [[ $? == 0 ]]
    then
      echo ${BRANCH}
    else
      cat ${OUTPUT}
      rm ${OUTPUT}
      exit 1
    fi
  else
    cat ${OUTPUT}
    rm ${OUTPUT}
    exit 2
  fi
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 3
fi

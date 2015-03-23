#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
VERSION=$2
BRANCH=$3
BASE_BRANCH=$4
ST2COMMON_INIT="st2common/st2common/__init__.py"
ST2CLIENT_INIT="st2client/st2client/__init__.py"
OUTPUT=/tmp/git-output-$DATE

cd ${REPO}
OUT=`$GIT checkout ${BASE_BRANCH} -q > $OUTPUT && $GIT pull origin ${BASE_BRANCH} -q > $OUTPUT && $GIT checkout -b ${BRANCH} -q`
if [[ $? == 0 ]]
then
  VERSIONOUT=`sed -i -e "s/\(__version__ = \).*/\1'${VERSION}'/" ${ST2COMMON_INIT}`
  if [[ $? == 0 ]]
  then
    VERSIONOUT=`sed -i -e "s/\(__version__ = \).*/\1'${VERSION}'/" ${ST2CLIENT_INIT}`
  else
    echo ${OUTPUT}
    exit 1
  fi
  if [[ $? == 0 ]]
  then
    OUT=`$GIT add $ST2COMMON_INIT $ST2CLIENT_INIT > $OUTPUT && $GIT commit -qm "Cutting branch for release - ${VERSION}" > $OUTPUT && $GIT push origin $BRANCH -q > $OUTPUT`
    if [[ $? == 0 ]]
    then
      echo ${BRANCH}
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
else
  cat ${OUTPUT}
  rm ${OUTPUT}
  exit 4
fi

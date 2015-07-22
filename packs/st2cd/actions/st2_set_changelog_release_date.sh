#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
BRANCH=$2
VERSION=$3
RELEASE_DATE=$4

if [[ -z $RELEASE_DATE ]]
then
    RELEASE_DATE=`date +"%B %d, %Y"`
fi

OUTPUT=/tmp/changelog_release_date-output-$DATE
CHANGELOG_FILE=${REPO}/CHANGELOG.rst
RELEASE_STRING="${VERSION} - ${RELEASE_DATE}"
echo ${RELEASE_STRING}
DASH_HEADER_CMD="printf '%.0s-' {1..${#RELEASE_STRING}}"
DASH_HEADER=$(/bin/bash -c "${DASH_HEADER_CMD}")
echo ${DASH_HEADER}

if [[ ! -d ${REPO} ]]
then
    echo "${REPO} does not exist."
    exit 1
fi

cd ${REPO}
OUT=`$GIT checkout ${BRANCH} -q > ${OUTPUT}`
if [[ $? == 0 ]]
then
    if [[ ! -f ${CHANGELOG_FILE} ]]
    then
        echo "File ${CHANGELOG_FILE} not found. Exiting..."
        exit 3
    else
        SED_REPLACE=`sed -i "s/in development/${RELEASE_STRING}/g" ${CHANGELOG_FILE}`
        if [[ $? == 0 ]]
        then
            SED_ADD_DASH_HEADER=`sed -i "/${RELEASE_STRING}/!b;n;c${DASH_HEADER}" ${CHANGELOG_FILE}`
            if [[ $? == 0 ]]
            then
                SED_IN_DEV=`sed -i "/${RELEASE_STRING}/i \in development\n--------------\n\n" ${CHANGELOG_FILE}`
                if [[ $? == 0 ]]
                then
                    exit 0
                else
                    echo "Failed sed add in development string."
                    exit 6
                fi
            else
                echo "Failed sed command for adding header."
                exit 5
            fi
        else
            echo "Failed sed replace."
            exit 4
        fi
    fi
else
    echo "Branch checkout failed. Branch=${BRANCH}."
    cat ${OUTPUT}
    rm -f ${OUTPUT}
    exit 2
fi

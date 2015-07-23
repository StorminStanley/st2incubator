#!/bin/bash

GIT=`which git`
REPO=$1
DATE=`date +%s`
VERSION=$2
BRANCH=$3
OUTPUT=/tmp/st2_set_version_info-output-$DATE
ST2COMMON_INIT="st2common/st2common/__init__.py"

cd ${REPO}
VERSIONOUT=`sed -i -e "s/\(__version__ = \).*/\1'${VERSION}'/" ${ST2COMMON_INIT}`
if [[ $? == 0 ]]
then
    OUT=`$GIT add ${ST2COMMON_INIT} > ${OUTPUT} && $GIT commit -qm "Setting version info for release - ${VERSION}" > ${OUTPUT}`
    if [[ $? == 0 ]]
    then
        echo "Version in ${ST2COMMON_INIT} set to ${VERSION}"
    else
        echo "Failed setting version info in ${ST2COMMON_INIT}"
        cat ${OUTPUT}
        rm -f ${OUTPUT}
        exit 2
    fi
else
    echo "Failed sed replace version in ${ST2COMMON_INIT}"
    cat ${OUTPUT}
    rm -f ${OUTPUT}
    exit 1
fi

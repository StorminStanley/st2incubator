#!/bin/bash
BUILD_NUMBER=$1
REPO=$2

cd $REPO
ST2VER=`grep version st2common/st2common/__init__.py | awk '{print $3}' | tr -d "'"`
CLIENTVER="${ST2VER}-${BUILD}"
sed -i "s/Release: [0-9]\+/Release: ${BUILD_NUMBER}/g" */packaging/rpm/*.spec
sed -i "s/Version:.*/Version: ${ST2VER}/g" */packaging/rpm/*.spec
sed -i "s/(.*)/(${ST2VER}-${BUILD_NUMBER})/g" */packaging/debian/changelog
sed -i "s/^VER=.*/VER=${ST2VER}/g" */Makefile
sed -i "s/RELEASE=[0-9]\+/RELEASE=${BUILD_NUMBER}/g" st2client/Makefile
sed -i "s~version=.*~version=\"${ST2VER}\",~" */setup.py
sed -i "s~__version__ =.*~__version__ ='${CLIENTVER}',~" st2client/__init__.py

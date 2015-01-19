#!/bin/bash
BUILD_NUMBER=$1
REPO=$2

cd $REPO
ST2VER=`grep version st2common/st2common/__init__.py | awk '{print $3}' | tr -d "'"`
sed -i "s/(.*)/(${ST2VER}-${BUILD_NUMBER})/g" */packaging/debian/changelog
sed -i "s/^VER=.*/VER=${ST2VER}/g" */Makefile
sed -i "s/RELEASE=[0-9]\+/RELEASE=${BUILD_NUMBER}/g" st2client/Makefile
sed -i "s~version=.*~version=\"${ST2VER}\"~" */setup.py
git checkout st2client/setup.py

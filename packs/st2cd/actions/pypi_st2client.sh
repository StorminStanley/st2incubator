#!/bin/bash

set -e

REPO=`pwd`/${1}

if [ ! -d ${REPO} ] && [ ! -h ${REPO} ]; then
    echo "ERROR: ${REPO} does not exists"
    exit 1
fi

cd ${REPO}/st2client
python setup.py sdist upload -r pypitest
python setup.py sdist upload -r pypi

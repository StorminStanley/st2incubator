#!/bin/bash

MISSING=""

BUILDDIR=$1
shift
PACKAGELIST=$@

if [ ! -d ${BUILDDIR} ]; then
    echo "ERROR: ${BUILDDIR} is not a valid directory"
    exit 2
fi

for PKG in $PACKAGELIST; do
    if [ ! -e ${BUILDDIR}/${PKG}* ]; then
        MISSING="${MISSING} ${PKG}"
    fi
done

if [ "$MISSING" != "" ]; then
    echo "ERROR: Missing Packages: ${MISSING}"
    exit 2
else
    echo "SUCCESS: All Packages were exist in ${BUILDDIR}"
    exit 0
fi
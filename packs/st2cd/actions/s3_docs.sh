#!/bin/bash

echo $@

REPO=$1
BUCKET=$2
shift
shift

cd $REPO

if [ "$#" -gt 0 ]; then
    for LOCATION in $@; do
        s3cmd put --recursive * s3://${BUCKET}${LOCATION}
    done
fi

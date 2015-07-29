#!/bin/bash

TARGET=$1

if [[ ! -d $TARGET ]]; then
    echo "$TARGET does not exist."
    exit 0
fi

echo "Removing $TARGET..."
rm -Rf $TARGET

if [[ -d $TARGET ]]; then
    echo "Unable to remove $TARGET."
    exit 1
fi

sleep 5

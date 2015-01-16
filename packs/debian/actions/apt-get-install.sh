#!/usr/bin/env bash

PACKAGE=$1
VERSION=""

if [ -z "$2" ]; then
  VERSION="=${2}"
fi

export DEBIAN_FRONTEND=noninteractive
sudo apt-get install ${PACKAGE}${VERSION}

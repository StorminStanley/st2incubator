#!/bin/bash

DEBTEST=`lsb_release -a 2> /dev/null | grep Distributor | awk '{print $3}'`

if [[ "$DEBTEST" == "Ubuntu" ]]; then
  TYPE="debs"
  PYTHONPACK="/usr/lib/python2.7/dist-packages"
elif [[ -f "/etc/redhat-release" ]]; then
  TYPE="rpms"
  PYTHONPACK="/usr/lib/python2.7/site-packages"
else
  echo "Unknown Operating System"
  exit 2
fi

INSTALL=`${PYTHONPACK}/st2common/bin/st2-setup-tests $1`

EXITCODE=$?
echo $INSTALL
exit $EXITCODE

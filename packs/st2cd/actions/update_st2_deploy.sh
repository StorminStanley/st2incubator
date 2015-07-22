#!/bin/bash

ST2_DEPLOY_PATH=$1
DOWNLOAD_SERVER=$2
PROTOCOL=$3

sed -i -e "s~\(DOWNLOAD_SERVER=\).*~\1'${PROTOCOL}://${DOWNLOAD_SERVER}'~g" ${ST2_DEPLOY_PATH}

sed -i -e "s~http://downloads.stackstorm.net~http://${DOWNLOAD_SERVER}~g" ${ST2_DEPLOY_PATH}
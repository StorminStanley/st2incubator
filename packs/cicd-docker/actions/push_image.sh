#!/bin/bash

DOCKER=`which docker`

if [[ -z ${DOCKER} ]]
then
    echo 'Install docker CLI.'
    exit 1
fi

REPO="${1}"

if [[ -z ${TAG} ]]
then
    OUTPUT=`docker push ${REPO}`
fi

if [[ $? == 0 ]]
then
    echo 'Pushed image successfully.'
    echo ${OUTPUT}
    exit 0
else
    echo 'Push image failed.'
    echo ${OUTPUT}
    exit 3
fi

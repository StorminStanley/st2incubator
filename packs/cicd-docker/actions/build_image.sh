#!/bin/bash

DOCKER=`which docker`

if [[ -z ${DOCKER} ]]
then
    echo 'Install docker CLI.'
    exit 1
fi

DOCKERFILE_PATH="${1}"
TAG="${2}"

if [[ ! -d $DOCKERFILE_PATH ]]
then
    echo "Directory does not exist. Quiting."
    exit 2
fi

if [[ -z ${TAG} ]]
then
    OUTPUT=`docker build ${DOCKERFILE_PATH}/`
else
    OUTPUT=`docker build -t ${TAG} ${DOCKERFILE_PATH}/`
fi

if [[ $? == 0 ]]
then
    echo 'Built image successfully.'
    echo ${OUTPUT}
    exit 0
else
    echo 'Build image failed.'
    echo ${OUTPUT}
    exit 3
fi

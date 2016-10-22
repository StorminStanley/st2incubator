#!/bin/bash
set -e

SSHUSERS="sshusers"
USERNAME=${1}
PASSWORD=${2}

if [ $(id -u ${USERNAME} &> /dev/null; echo $?) != 0 ]
then
    echo "########## Creating user: ${USERNAME} ##########"
    useradd ${USERNAME}
    echo -e "${PASSWORD}\n${PASSWORD}" | passwd ${USERNAME}
    usermod –a –G ${SSHUSERS} ${USERNAME}
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

    if [ $(grep ${USERNAME} /etc/sudoers.d/* &> /dev/null; echo $?) != 0 ]
    then
        echo "${USERNAME}    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/st2
    fi
fi

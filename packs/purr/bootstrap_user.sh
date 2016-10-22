#!/bin/bash
set -e

SYSTEMUSER="stanley"
USER_PUB_KEY_FILE="https://raw.githubusercontent.com/StackStorm/st2incubator/master/packs/purr/stanley_rsa.pub"

create_user() {
    if [ $(id -u ${SYSTEMUSER} &> /devnull; echo $?) != 0 ]
    then
        echo "########## Creating system user: ${SYSTEMUSER} ##########"
        groupadd -g 706 ${SYSTEMUSER}
        useradd -u 706 -g 706 ${SYSTEMUSER}
        mkdir -p /home/${SYSTEMUSER}/.ssh
        curl -Ss -o /home/${SYSTEMUSER}/.ssh/authorized_keys ${USER_PUB_KEY_FILE}
        chmod 0700 /home/${SYSTEMUSER}/.ssh
        chmod 0600 /home/${SYSTEMUSER}/.ssh/authorized_keys
        chown -R ${SYSTEMUSER}:${SYSTEMUSER} /home/${SYSTEMUSER}
        if [ $(grep 'stanley' /etc/sudoers.d/* &> /dev/null; echo $?) != 0 ]
        then
            echo "${SYSTEMUSER}    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/st2
        fi
    fi
}

create_user

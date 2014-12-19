#!/bin/bash

SYSTEMUSER="stanley"

create_user() {

  if [ $(id -u ${SYSTEMUSER} &> /devnull; echo $?) != 0 ]
  then
    echo "########## Creating system user: ${SYSTEMUSER} ##########"
    useradd ${SYSTEMUSER}
    mkdir -p /home/${SYSTEMUSER}/.ssh
    curl -Ss -o /home/${SYSTEMUSER}/.ssh/authorized_keys https://gist.githubusercontent.com/DoriftoShoes/d729b0d769a56672a6cd/raw/ca17ed9d6fe25cab0c574a242557612925c4c0e2/stanley_rsa.pub
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

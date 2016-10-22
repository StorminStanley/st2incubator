#!/bin/bash
set -e

USERNAME=${1}
PASSWORD=${2}

if [ $(id -u ${USERNAME} &> /dev/null; echo $?) != 0 ]
then
    echo "Updating sshd_config to allow password authentication..."
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    service ssh restart

    echo "Creating user ${USERNAME}..."
    useradd -d /home/${USERNAME} -m ${USERNAME}
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

    if [ $(grep ${USERNAME} /etc/sudoers.d/* &> /dev/null; echo $?) != 0 ]
    then
        echo "${USERNAME}    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/st2
    fi

    echo -e "${PASSWORD}\n${PASSWORD}" | passwd ${USERNAME}
fi

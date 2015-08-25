#!/bin/bash
set -e

DISTRO=$1

# Remove service file.
if [ "${DISTRO}" == "ubuntu" ]; then
    UPSTART_FILE=/etc/init/mistral.conf
    rm -f ${UPSTART_FILE}
elif [ "${DISTRO}" == "fedora" ]; then
    SYSTEMD_FILE=/etc/systemd/system/mistral.service
    rm -f ${SYSTEMD_FILE}
else
    >&2 echo "ERROR: ${DISTRO} is an unsupported Linux distribution."
    exit 1
fi

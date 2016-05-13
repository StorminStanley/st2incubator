#!/bin/bash
set -e

DISTRO=$1

# Remove service file.
if [ "${DISTRO}" == "ubuntu" ]; then
    ENG_UPSTART_FILE=/etc/init/mistral.conf
    API_UPSTART_FILE=/etc/init/mistral-api.conf
    rm -f ${ENG_UPSTART_FILE}
    rm -f ${API_UPSTART_FILE}
elif [ "${DISTRO}" == "fedora" ]; then
    ENG_SYSTEMD_FILE=/etc/systemd/system/mistral.service
    API_UPSTART_FILE=/etc/systemd/system/mistral-api.service
    rm -f ${ENG_SYSTEMD_FILE}
    rm -f ${API_SYSTEMD_FILE}
else
    >&2 echo "ERROR: ${DISTRO} is an unsupported Linux distribution."
    exit 1
fi

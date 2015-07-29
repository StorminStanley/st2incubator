#!/bin/bash
set -e

DISTRO=$1
MISTRAL_PATH=$2

# Setup service file.
if [ "${DISTRO}" == "ubuntu" ]; then
    UPSTART_FILE=/etc/init/mistral.conf
    rm -f ${UPSTART_FILE}
    touch ${UPSTART_FILE}

    cat << MISTRAL_UPSTART >${UPSTART_FILE}
description "Mistral Workflow Service"

start on runlevel [2345]
stop on runlevel [016]

exec ${MISTRAL_PATH}/.venv/bin/python ${MISTRAL_PATH}/mistral/cmd/launch.py --config-file ${MISTRAL_PATH}/mistral.conf --log-config-append ${MISTRAL_PATH}/wf_trace_logging.conf
MISTRAL_UPSTART

elif [ "${DISTRO}" == "fedora" ]; then
    SYSTEMD_FILE=/etc/systemd/system/mistral.service
    rm -f ${SYSTEMD_FILE}
    touch ${SYSTEMD_FILE}

    cat << MISTRAL_SYSTEMD >${SYSTEMD_FILE}
[Unit]
Description=Mistral Workflow Service

[Service]
ExecStart=${MISTRAL_PATH}/.venv/bin/python ${MISTRAL_PATH}/mistral/cmd/launch.py --config-file ${MISTRAL_PATH}/mistral.conf --log-config-append ${MISTRAL_PATH}/wf_trace_logging.conf

[Install]
WantedBy=multi-user.target
MISTRAL_SYSTEMD

    systemctl enable mistral
else
    >&2 echo "ERROR: ${DISTRO} is an unsupported Linux distribution."
    exit 1
fi

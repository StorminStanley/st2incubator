#!/bin/bash
set -e

DISTRO=$1
MISTRAL_PATH=$2
CONFIG_PATH=/etc/mistral

# Stop service
service mistral stop || true

# Setup service file.
if [ "${DISTRO}" == "ubuntu" ]; then
    UPSTART_FILE=/etc/init/mistral.conf
    rm -f ${UPSTART_FILE}
    touch ${UPSTART_FILE}

    cat << MISTRAL_UPSTART >${UPSTART_FILE}
description "Mistral Engine Service"

start on runlevel [2345]
stop on runlevel [016]

exec ${MISTRAL_PATH}/.venv/bin/python ${MISTRAL_PATH}/mistral/cmd/launch.py --config-file ${CONFIG_PATH}/mistral.conf --log-config-append ${CONFIG_PATH}/wf_trace_logging.conf --server "engine, executor"
MISTRAL_UPSTART

elif [ "${DISTRO}" == "fedora" ]; then
    SYSTEMD_FILE=/etc/systemd/system/mistral.service
    rm -f ${SYSTEMD_FILE}
    touch ${SYSTEMD_FILE}

    cat << MISTRAL_SYSTEMD >${SYSTEMD_FILE}
[Unit]
Description=Mistral Engine Service

[Service]
ExecStart=${MISTRAL_PATH}/.venv/bin/python ${MISTRAL_PATH}/mistral/cmd/launch.py --config-file ${CONFIG_PATH}/mistral.conf --log-config-append ${CONFIG_PATH}/wf_trace_logging.conf --server "engine, executor"

[Install]
WantedBy=multi-user.target
MISTRAL_SYSTEMD

    systemctl enable mistral
else
    >&2 echo "ERROR: ${DISTRO} is an unsupported Linux distribution."
    exit 1
fi

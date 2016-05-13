#!/bin/bash
set -e

DISTRO=$1
MISTRAL_PATH=$2

# Stop service
service mistral-api stop || true

# Kill any orphaned processes
pkill -f gunicorn || true

# Setup service file.
if [ "${DISTRO}" == "ubuntu" ]; then
    UPSTART_FILE=/etc/init/mistral-api.conf
    rm -f ${UPSTART_FILE}
    touch ${UPSTART_FILE}

    cat << MISTRAL_API_UPSTART >${UPSTART_FILE}
description "Mistral API Server"

start on runlevel [2345]
stop on runlevel [016]

chdir ${MISTRAL_PATH}

exec ${MISTRAL_PATH}/.venv/bin/gunicorn -b 0.0.0.0:8989 -w 2 mistral.api.wsgi --log-file /var/log/mistral-api.log --log-level DEBUG --timeout 180 --graceful-timeout 180
MISTRAL_API_UPSTART

elif [ "${DISTRO}" == "fedora" ]; then
    SYSTEMD_FILE=/etc/systemd/system/mistral-api.service
    rm -f ${SYSTEMD_FILE}
    touch ${SYSTEMD_FILE}

    cat << MISTRAL_API_SYSTEMD >${SYSTEMD_FILE}
[Unit]
Description=Mistral API Server

[Service]
WorkingDirectory=${MISTRAL_PATH}
ExecStart=${MISTRAL_PATH}/.venv/bin/gunicorn -b 0.0.0.0:8989 -w 2 mistral.api.wsgi --log-file /var/log/mistral-api.log --log-level DEBUG --timeout 180 --graceful-timeout 180

[Install]
WantedBy=multi-user.target
MISTRAL_API_SYSTEMD

    systemctl enable mistral-api
else
    >&2 echo "ERROR: ${DISTRO} is an unsupported Linux distribution."
    exit 1
fi

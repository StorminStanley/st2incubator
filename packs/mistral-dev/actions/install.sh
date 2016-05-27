#!/bin/bash
set -e

REPO_MAIN=$1
REPO_CLIENT=$2
REPO_ACTION=$3

# Check that the repos exist.
REPOS=(
    ${REPO_MAIN}
    ${REPO_CLIENT}
    ${REPO_ACTION}
)

for REPO in "${REPOS[@]}"
do
    if [[ ! -d "${REPO}" ]]; then
        >&2 echo "ERROR: ${REPO} does not exist."
        exit 1
    fi
done

# Setup and activate virtualenv.
cd ${REPO_MAIN}
if [[ -d "${REPO_MAIN}/.venv" ]]; then
    rm -rf ${REPO_MAIN}/.venv
fi
virtualenv --no-site-packages .venv
. ${REPO_MAIN}/.venv/bin/activate

# Temporary hack around the amqp dependency problem
pip install "amqp>=1.4.0,<2.0.0" 

# Setup mistral.
cd ${REPO_MAIN}
sed -i 's/yaql>=0.2.7,!=0.3.0/yaql>=0.2.7,!=0.3.0,<1.0.0/g' requirements.txt
pip install -q -r requirements.txt
pip install gunicorn

# Temporary hack to bypass conflict in pbr version.
VENV_PKG_DIR="${REPO_MAIN}/.venv/local/lib/python2.7/site-packages"
YAQL_REQ_FILE="${VENV_PKG_DIR}/yaql-0.2.7-py2.7.egg-info/requires.txt"
if [[ -f "${YAQL_REQ_FILE}" ]]; then
    sed -i 's/pbr>=0.6,!=0.7,<1.0/pbr<2.0,>=0.11/g' ${YAQL_REQ_FILE}
fi

# Temporary hack to get around oslo.utils bug.
pip install -q netifaces

pip install -U setuptools
python setup.py develop

# Setup plugins for custom actions.
cd ${REPO_ACTION}
python setup.py develop

# Setup mistral client.
cd ${REPO_CLIENT}
pip install -q -r requirements.txt
python setup.py develop

# Deactivate virtualenv.
deactivate

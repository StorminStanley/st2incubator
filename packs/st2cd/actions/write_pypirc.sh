#!/bin/bash

set -e

PYPIRC=~/.pypirc
USERNAME=${1}
PASSWORD=${2}

if [ -e "${PYPIRC}" ]; then
    rm ${PYPIRC}
fi

touch ${PYPIRC}
cat <<pypirc >${PYPIRC}
[distutils]
index-servers =
    pypi
    pypitest

[pypi]
repository: https://pypi.python.org/pypi
username: ${USERNAME}
password: ${PASSWORD}

[pypitest]
repository: https://testpypi.python.org/pypi
username: ${USERNAME}
password: ${PASSWORD}
pypirc

if [ ! -e "${PYPIRC}" ]; then
    echo "ERROR: Unable to write file ~/.pypirc"
    exit 1
fi

exit 0

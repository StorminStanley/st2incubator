#!/bin/bash

PYTHON=`which python`
REPO=$1
DATE=`date +%s`
BRANCH=$2
CONFIG_DIR=$3
OUTPUT=/tmp/output-$DATE

touch $OUTPUT

if [[ ! -d "$REPO" ]]
then
  echo "ERROR: repo ${REPO} doesn't exist."
  exit 1
fi

cd $REPO

install_mistral() {
    # XXX: Ideally these steps should be actions of their own workflow.
    virtualenv --no-site-packages .venv
    if [[ $? == 0 ]]
    then
        echo 'Failed creating virtualenv'
        exit 2
    else
        . $REPO/mistral/.venv/bin/activate
    fi

    git checkout -q -b ${BRANCH} origin/${BRANCH}
    if [[ $? == 0 ]]
    then
        echo 'Failed checking out branch $BRANCH'
        exit 3
    fi

    pip install -r requirements.txt >> $OUTPUT
    if [[ $? == 0 ]]
    then
        echo 'Failed installing pip requirements for branch: $BRANCH'
        exit 4
    fi

    pip install -q mysql-python
    if [[ $? == 0 ]]
    then
        echo 'Failed installing mysql-python'
        exit 4
    fi

    python setup.py develop >> $OUTPUT
    if [[ $? == 0 ]]
    then
        echo 'Failed installing mistral'
        exit 4
    fi
    echo 'SUCCESS: Installed mistral.'
}

setup_mistral_config()
{
#XXX: Figure out how to make mistral use a db name other than 'mistral'
config=${CONFIG_DIR}/mistral.conf
if [ -e "$config" ]; then
    rm $config
fi
touch $config
cat <<mistral_config >$config
[database]
connection=mysql://mistral:StackStorm@localhost/mistral-itests
max_pool_size=50
[pecan]
auth_enable=false
mistral_config
echo 'SUCCESS: Mistral config in ${CONFIG_DIR}/mistral.conf'
}

setup_mysql_db() {
    mysql -uroot -pStackStorm -e "DROP DATABASE IF EXISTS mistral-itests"
    mysql -uroot -pStackStorm -e "CREATE DATABASE mistral-itests"
    mysql -uroot -pStackStorm -e "GRANT ALL PRIVILEGES ON mistral-itests.* TO 'mistral-itests'@'%' IDENTIFIED BY 'StackStorm'"
    mysql -uroot -pStackStorm -e "FLUSH PRIVILEGES"
    $REPO/.venv/bin/python $REPO/tools/sync_db.py --config-file ${CONFIG_DIR}/mistral.conf
}

install_mistral
setup_mistral_config
setup_mysql_db

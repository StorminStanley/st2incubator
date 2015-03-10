#!/bin/bash

PYTHON=`which python`
REPO=$1
DATE=`date +%s`
BRANCH=$2
CONFIG_DIR=$3
ST2_ACTIONS_DIR=$4
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
    if [[ $? != 0 ]]
    then
        echo 'Failed creating virtualenv'
        exit 2
    else
        . $REPO/.venv/bin/activate
    fi

    git checkout -q -b ${BRANCH} origin/${BRANCH}
    pip install -r requirements.txt >> $OUTPUT
    if [[ $? != 0 ]]
    then
        echo 'Failed installing pip requirements for branch: $BRANCH'
        exit 3
    fi

    pip install -q mysql-python
    if [[ $? != 0 ]]
    then
        echo 'Failed installing mysql-python'
        exit 4
    fi

    python setup.py develop >> $OUTPUT
    if [[ $? != 0 ]]
    then
        echo 'Failed installing mistral'
        exit 5
    fi
    echo 'SUCCESS: Installed mistral.'
    deactivate >> $OUTPUT
}

install_st2action() {
    if [[ ! -d "$ST2_ACTIONS_DIR" ]]
    then
        echo "ERROR: st2actions dir $ST2_ACTIONS_DIR not found."
        exit 6
    fi

    . $REPO/.venv/bin/activate
    if [[ $? != 0 ]]
    then
        echo 'ERROR: Failed activating mistral virtualenv'
        exit 7
    fi

    python setup.py develop >> $OUTPUT
    if [[ $? != 0 ]]
    then
        echo 'ERROR: Failed install st2action into mistral virtualenv'
        exit 8
    fi
    deactivate
    echo "SUCCESS: Installed st2action."
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
connection=mysql://mistral:StackStorm@localhost/mistral
max_pool_size=50
[pecan]
auth_enable=false
mistral_config
echo "SUCCESS: Mistral config in ${CONFIG_DIR}/mistral.conf"
}

setup_mysql_db() {
    mysql -uroot -pStackStorm -e "DROP DATABASE IF EXISTS mistral"
    mysql -uroot -pStackStorm -e "CREATE DATABASE mistral"
    mysql -uroot -pStackStorm -e "GRANT ALL PRIVILEGES ON mistral.* TO 'mistral'@'%' IDENTIFIED BY 'StackStorm'"
    mysql -uroot -pStackStorm -e "FLUSH PRIVILEGES"
    $REPO/.venv/bin/python $REPO/tools/sync_db.py --config-file ${CONFIG_DIR}/mistral.conf
}

install_mistral
install_st2action
setup_mistral_config
setup_mysql_db
rm $OUTPUT

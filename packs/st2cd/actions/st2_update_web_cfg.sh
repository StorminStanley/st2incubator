#!/bin/bash

if [[ -z $1 ]]; then
    WEBUI_CONFIG_PATH="/opt/stackstorm/static/webui/config.js"
else
	WEBUI_CONFIG_PATH=$1
fi

echo "Updating ${WEBUI_CONFIG_PATH}..."
echo -e "'use strict';
angular.module('main')
.constant('st2Config', {
hosts: [{
  name: 'StackStorm',
  url: '//:9101',
  auth: '//:9100'
}]
});" > ${WEBUI_CONFIG_PATH}

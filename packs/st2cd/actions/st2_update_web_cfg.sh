#!/bin/bash

if [[ -z $1 ]]; then
    WEBUI_CONFIG_PATH="/opt/stackstorm/static/webui/config.js"
else
	WEBUI_CONFIG_PATH=$1
fi

echo -e "'use strict';
angular.module('main')
.constant('st2Config', {
hosts: [{
  name: 'StackStorm',
  url: '',  # use current url from the address bar
  auth: true  # use current url from the address bar, replace the port with default st2auth port
}]
});" > ${WEBUI_CONFIG_PATH}
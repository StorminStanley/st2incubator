#!/usr/bin/env python

import os
import sys
import time
import json
import argparse
from st2client import models
from st2client.client import Client

END_STATES = ['succeeded', 'failed']
ST2HOST = 'localhost'

parser = argparse.ArgumentParser()

parser.add_argument('--name', action="store", dest="name", required=True)
parser.add_argument('--action', action="store", dest="action", required=True)
parser.add_argument('--params', action="store", dest="params")
parser.add_argument('--token', action="store", dest="token")

args = parser.parse_args()
runner = None

os.environ['ST2_AUTH_TOKEN'] = args.token


def runAction(action_ref, params):

    client = Client()
    action_exec_mgr = client.managers['LiveAction']

    execution = models.LiveAction()
    execution.action = action_ref
    execution.parameters = param_parser(params)
    actionexec = action_exec_mgr.create(execution)

    while actionexec.status not in END_STATES:
        time.sleep(2)
        actionexec = action_exec_mgr.get_by_id(actionexec.id)

    return actionexec


def param_parser(params):
    parameters = {}
    if params is not None:
        param_list = params.split(' ')
        for p in param_list:
            if '=' in p:
                k, v = p.split('=', 1)
                if ',' in v:
                    v = filter(None, v.split(','))
            else:
                k = 'cmd'
                v = p
            parameters[k] = v
    return parameters

actionexec = runAction(action_ref=args.action, params=args.params)
output = {args.name: actionexec.result}

print json.dumps(output)
if actionexec.status != 'succeeded':
    sys.exit(2)

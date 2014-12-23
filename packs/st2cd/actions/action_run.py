#!/usr/bin/env python

import os, sys, time, json, argparse
from st2client import models
from st2client.client import Client

END_STATES= ['succeeded','failed']
ST2HOST = 'localhost'

parser = argparse.ArgumentParser()

parser.add_argument('--name', action="store", dest="name", required=True)
parser.add_argument('--action', action="store", dest="action", required=True)
parser.add_argument('--params', action="store", dest="params")

args = parser.parse_args()
runner = None

def runAction(action_ref,params):
    st2_endpoints = {
      'action': "http://%s:9101" % ST2HOST,
      'reactor': "http://%s:9102" % ST2HOST,
      'datastore': "http://%s:9103" % ST2HOST
    }

    client = Client(st2_endpoints)
    action_exec_mgr = client.managers['ActionExecution']
    runner_mgr = client.managers['RunnerType']

    execution = models.ActionExecution()
    execution.action = action_ref
    execution.parameters = param_parser(params)
    action_exec_mgr = client.managers['ActionExecution']
    actionexec = action_exec_mgr.create(execution)

    while actionexec.status not in END_STATES:
      time.sleep(2)
      actionexec = action_exec_mgr.get_by_id(actionexec.id)

    return actionexec

def normalize(name, value):
    if name in runner.runner_parameters:
        param = runner.runner_parameters[name]
        if 'type' in param and param['type'] in transformer:
            return transformer[param['type']](value)

    if name in action.parameters:
        param = action.parameters[name]
        if 'type' in param and param['type'] in transformer:
            return transformer[param['type']](value)
    return value

def param_parser(params):
    parameters = {}
    if params is not None:
        param_list = params.split(' ')
        for p in param_list:
            if '=' in p:
                k, v = p.split('=',1)
                if ',' in v:
                    v = filter(None,v.split(','))
                    
            else:
                k = 'cmd'
                v = p
            parameters[k] = v
    return parameters

actionexec = runAction(action_ref=args.action,params=args.params)
output = {args.name: actionexec.result}

print json.dumps(output)
if actionexec.status != 'succeeded':
    sys.exit(2)

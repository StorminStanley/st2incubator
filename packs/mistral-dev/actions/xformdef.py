import json
import os
import six
import yaml

from st2actions.runners import pythonrunner
from st2actions.runners.mistral import utils
from st2client import client


class MistralDSLTransformer(pythonrunner.Action):

    def __init__(self, config=None):
        super(MistralDSLTransformer, self).__init__(config)
        self.st2client = client.Client()

    def _transform_action(self, spec, action_key, input_key):

        if action_key not in spec or spec.get(action_key) == 'st2.action':
            return

        utils._eval_inline_params(spec, action_key, input_key)

        action_ref = spec.get(action_key)

        if self.st2client.actions.get_by_ref_or_id(action_ref):
            spec[action_key] = 'st2.action'
            spec[input_key] = {
                'ref': action_ref,
                'parameters': spec[input_key]
            }

    def run(self, definition):
        if os.path.isfile(definition):
            with open(definition, 'r') as f:
                definition = f.read()

        spec = yaml.safe_load(definition)

        if 'version' not in spec:
            raise Exception('Unknown version. Only version 2.0 is supported.')

        if spec['version'] != '2.0':
            raise Exception('Only version 2.0 is supported.')

        # Transform adhoc actions
        for action_name, action_spec in six.iteritems(spec.get('actions', {})):
            self._transform_action(action_spec, 'base', 'base-input')

        # Determine if definition is a workbook or workflow
        is_workbook = 'workflows' in spec

        # Transform tasks
        if is_workbook:
            for workflow_name, workflow_spec in six.iteritems(spec.get('workflows', {})):
                for task_name, task_spec in six.iteritems(workflow_spec.get('tasks')):
                    self._transform_action(task_spec, 'action', 'input')
        else:
            for key, value in six.iteritems(spec):
                if 'tasks' in value:
                    for task_name, task_spec in six.iteritems(value.get('tasks')):
                        self._transform_action(task_spec, 'action', 'input')

        return yaml.safe_dump(spec, default_flow_style=False)

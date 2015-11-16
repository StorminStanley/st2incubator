import jinja2
import six
import os

from st2actions.runners.pythonrunner import Action
from st2client.client import Client


class FormatResultAction(Action):
    def __init__(self, config):
        super(FormatResultAction, self).__init__(config)
        api_url = os.environ.get('ST2_ACTION_API_URL', None)
        token = os.environ.get('ST2_ACTION_AUTH_TOKEN', None)
        self.client = Client(api_url=api_url, token=token)
        self.jinja = jinja2.Environment(trim_blocks=True, lstrip_blocks=True)
        self.jinja.tests['in'] = lambda item, list: item in list

    def run(self, execution):
        context = {
            'six': six,
            'execution': execution
        }

        alias_id = execution['context'].get('action_alias_ref', {}).get('id', None)
        if alias_id:
            alias = self.client.managers['ActionAlias'].get_by_id(alias_id)

            context.update({
                'alias': alias
            })

        if alias_id and alias and hasattr(alias, 'result'):
            enabled = alias.result.get('enabled', True)

            if enabled and 'format' in alias.result:
                return self.jinja.from_string(alias.result['format']).render(context)
        else:
            path = os.path.dirname(os.path.realpath(__file__))
            with open(os.path.join(path, 'templates/default.j2'), 'r') as f:
                return self.jinja.from_string(f.read()).render(context)

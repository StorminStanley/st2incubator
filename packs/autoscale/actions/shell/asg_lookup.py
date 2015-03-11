from st2actions.runners.pythonrunner import Action
from st2client.client import Client
from st2client.models import KeyValuePair

class ASGLookup(Action):
    def run(self, application_name):
        client = Client(base_url='http://localhost')
        keys = client.keys.get_all()
        asg = ""

        for key in keys:
            if ('asg' in key.name) and (key.value == application_name):
                asg = key.name.split('.')[1]

        return asg

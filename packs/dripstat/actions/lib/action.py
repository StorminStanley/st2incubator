from st2actions.runners.pythonrunner import Action
import requests

class DripstatBaseAction(Action):
    def __init__(self, config):
        super(DripstatBaseAction, self).__init__(config)

    def _api_request(self, endpoint, params={}):
        url = 'https://api.dripstat.com/api/v1/' + endpoint
        default_params = { 'clientId': self.config['api_key'] }
        return requests.get(url, params=params.update(default_params))

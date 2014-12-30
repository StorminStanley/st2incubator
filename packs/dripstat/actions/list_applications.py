from lib import action

class DripstatListApplications(action.DripstatBaseAction):
    def run(self):
        return self._api_request('apps')

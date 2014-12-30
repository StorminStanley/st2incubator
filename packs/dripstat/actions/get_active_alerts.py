from lib import action

class DripstatGetActiveAlerts(action.DripstatBaseAction):
    def run(self, app_id):
        params = { 'appId': app_id }
        return self._api_request('alerts', params=params)

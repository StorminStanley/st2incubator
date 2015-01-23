from st2reactor.sensor.base import PollingSensor
import requests

__all_ = [
    'DripstatAlertSensor'
]

BASE_URL = 'https://api.dripstat.com/api/v1'

class DripstatAlertSensor(PollingSensor):
    def __init__(self, sensor_service, config=None, poll_interval=None):
        super(DripstatAlertSensor, self).__init__(sensor_service=sensor_service,
                                                  config=config,
                                                  poll_interval=poll_interval)
    def setup(self):
        self._applications = self._api_request(self, endpoint='/apps')

    def poll(self):
        for application in self._applications:
            alerts = self._api_request(self, endpoint='/alerts', params={'appId': application['id']})
            for alert in alerts:
                self._dispatch_trigger_for_alert(application=application['name'], alert=alert)

    def cleanup(self):
        pass

    def add_trigger(self):
        pass

    def update_trigger(self):
        pass

    def remove_trigger(self):
        pass

    def _api_request(self, endpoint, params={}):
        url = BASE_URL + endpoint
        default_params = { 'clientId': self.config['api_key'] }
        return requests.get(url, params=params.update(default_params))

    def _dispatch_trigger_for_alert(self, application, alert):
        trigger = self._trigger_ref
        payload = {
            app_name: application,
            alert_type: alert['name'],
            started_at: alert['startedAt'],
            jvm_host: alert['jvmHost']
        }
        self._sensor_service.dispatch(trigger=trigger, payload=payload)


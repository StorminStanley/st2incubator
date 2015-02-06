from st2reactor.sensor.base import PollingSensor

__all_ = [
    'AutoscaleBalloonManagerSensor'
]

eventlet.monkey_patch(
    os=True,
    select=True,
    socket=True,
    thread=True,
    time=True)

class AutoscaleBalloonManagerSensor(PollingSensor):
    def __init__(self, sensor_service, config=None, poll_interval=None):
        super(AutoscaleBalloonManagerSensor, self).__init__(sensor_service=sensor_service,
                                                  config=config,
                                                  poll_interval=poll_interval)

        self._trigger_ref = 'autoscale.deflate'
        self._logger = self._sensor_service.get_logger(__name__)
#self._sensor_service.set_value(name='last_id', value=last_id)

    def setup(self):
        pass

    def poll(self):
        # Get all active ASGs
        pass

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        pass

    def update_trigger(self, trigger):
        pass

    def remove_trigger(self, trigger):
        pass

    def _dispatch_trigger_for_alert(self, asg):
        trigger = self._trigger_ref
        payload = {
            'asg': asg,
        }
        self._sensor_service.dispatch(trigger=trigger, payload=payload)

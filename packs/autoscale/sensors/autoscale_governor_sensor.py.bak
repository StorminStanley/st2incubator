import time
from st2reactor.sensor.base import PollingSensor

__all_ = [
    'AutoscaleGovernorSensor'
]

eventlet.monkey_patch(
    os=True,
    select=True,
    socket=True,
    thread=True,
    time=True)

class AutoscaleGovernorSensor(PollingSensor):
    def __init__(self, sensor_service, config=None, poll_interval=None):
        super(AutoscaleGovernorSensor, self).__init__(sensor_service=sensor_service,
                                                      config=config,
                                                      poll_interval=poll_interval)
        self._logger = self._sensor_service.get_logger(__name__)
        self._kvp_get = self.sensor_service.get_value
        self._trigger = {
            'expand': 'ScaleUpPulse',
            'deflate': 'ScaleDownPulse'
        }
        self._bound = {
            'expand': 'max',
            'deflate': 'min'
        }

    def setup(self):
        pass

    def poll(self):
        alerting_apps = []
        stable_apps   = []

        # Get all the ASG related keys in the Key Store
        kvps = self._sensor_service.list_values(local=False, prefix='asg.')

        # Sort out which Applications are actively alerting, and which are not.
        for kvp in kvps:
            if 'active_incident' in kvp.name:
                asg_data = kvp.name.split('.')
                asg      = asg_data[1]
                app_name = self._kvp_get("asg.%s.application_name".format(asg))
                if kvp.value == True:
                    alerting_apps.append(asg, app_name)
                else:
                    stable_apps.append(asg, app_name)

        # Attempt to determine if an ASG needs to scale up...
        for app in alerting_apps:
            self._process_app(asg, app, 'expand')

        # ... or down
        for app in stable_apps:
            self._process_app(asg, app, 'deflate')

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        pass

    def update_trigger(self, trigger):
        pass

    def remove_trigger(self, trigger):
        pass

    def _process_app(self, asg, app, action):
        trigger_type         = self._trigger[action]
        bound                = self._bound[action]
        last_event_timestamp = self._kvp_get("asg.%s.last_%s_timestamp".format(asg, action))
        event_delay          = self._kvp_get("asg.%s.%s_delay".format(asg, action))
        current_node_count   = self._kvp_get("asg.%s.total_nodes".format(asg))
        node_bound           = self._kvp_get("asg.%s.%s_nodes".format(asg, bound))
        total_nodes          = self._kvp_get("asg.%s.total_nodes".format(asg))

        # See if an ASG is even eligible to be acted upon, min or max.
        bound_check = getattr(self, "_%s_bound_check".format(bound))(node_bound, total_nodes)
        delay_check = self._event_delay_check(last_event_timestamp, event_delay)
        if bound_check and delay_check:
            self._dispatch_trigger(trigger_type, asg)

    def _event_delay_check(self, last_event_timestamp, event_delay):
        check = True if last_event_timestamp + deflate_delay < int(time.time()) else False
        return check

    def _max_bound_check(self, max_nodes, total_nodes):
        check = True if total_nodes < max_nodes else False
        return check

    def _min_bound_check(self, min_nodes, total_nodes):
        check = True if total_nodes > max_nodes else False
        return check

    def _dispatch_trigger(self, trigger, asg):
        payload = {
            'asg': asg,
        }
        self._sensor_service.dispatch(trigger=trigger, payload=payload)

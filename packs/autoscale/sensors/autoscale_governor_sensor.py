import time
import eventlet
import ast
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
    def __init__(self, sensor_service, config=None, poll_interval=30):
        super(AutoscaleGovernorSensor, self).__init__(sensor_service=sensor_service,
                                                  config=config,
                                                  poll_interval=poll_interval)
        self._logger = self._sensor_service.get_logger(__name__)
        self._kvp_get = self._sensor_service.get_value

        self._trigger = {
            'expand': 'autoscale.ScaleUpPulse',
            'deflate': 'autoscale.ScaleDownPulse'
        }
        self._bound = {
            'expand': 'max',
            'deflate': 'min'
        }

    def setup(self):
        pass

    def poll(self):
        alerting_asgs = []
        stable_asgs   = []

        # Get all the ASG related keys in the Key Store
        kvps = self._sensor_service.list_values(local=False, prefix='asg.')

        # Sort out which Applications are actively alerting, and which are not.
        for kvp in kvps:
            if 'active_incident' in kvp.name:
                asg_data = kvp.name.split('.')
                asg      = asg_data[1]
                if ast.literal_eval(kvp.value):
                    alerting_asgs.append(asg)
                else:
                    stable_asgs.append(asg)

        # Attempt to determine if an ASG needs to scale up...
        for asg in alerting_asgs:
            self._process_asg(asg, 'expand')

        # ... or down
        for asg in stable_asgs:
            self._process_asg(asg, 'deflate')

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        pass

    def update_trigger(self, trigger):
        pass

    def remove_trigger(self, trigger):
        pass

    def _process_asg(self, asg, action):
        trigger_type         = self._trigger[action]
        bound                = self._bound[action]

        last_event_timestamp = self._kvp_get('asg.%s.last_%s_timestamp' % (asg, action), local=False)
        event_delay          = self._kvp_get('asg.%s.%s_delay' % (asg, action), local=False)
        current_node_count   = self._kvp_get('asg.%s.total_nodes' % (asg), local=False)
        node_bound           = self._kvp_get('asg.%s.%s_nodes' % (asg, bound), local=False)
        total_nodes          = self._kvp_get('asg.%s.total_nodes' % (asg), local=False)

        # ensure we have all the required variables
        if last_event_timestamp and event_delay and current_node_count and node_bound and total_nodes:
            # See if an ASG is even eligible to be acted upon, min or max.
            bound_check = getattr(self, '_%s_bound_check' % bound)(int(node_bound), int(total_nodes))
            delay_check = self._event_delay_check(int(last_event_timestamp), int(event_delay))
            if bound_check and delay_check:
                self._dispatch_trigger(trigger_type, asg)
        else:
            self._logger.info("AutoScaleGovernor: Not all K/V pairs exist for ASG %s. Skipping..." % asg)

    def _event_delay_check(self, last_event_timestamp, event_delay):
        check = True if last_event_timestamp + (event_delay * 60) < int(time.time()) else False
        return check

    def _max_bound_check(self, max_nodes, total_nodes):
        """
        Make sure we have not reached the threshold and are not above max_nodes.

        We only want to send scale up pulse if we are not above max_nodes threshold.
        """
        check = True if total_nodes < max_nodes else False
        return check

    def _min_bound_check(self, min_nodes, total_nodes):
        """
        Make sure we have not reached the min_nodes threshold.

        We only want to scale down if current number of nodes is greater than min_nodes.
        """
        check = True if total_nodes > min_nodes else False
        return check

    def _dispatch_trigger(self, trigger, asg):
        payload = {
            'asg': asg,
        }
        self._sensor_service.dispatch(trigger=trigger, payload=payload)

from lib.base import BaseZabbixAction

__all__ = [
    'AckZabbixEventAction'
]


class AckZabbixEventAction(BaseZabbixAction):
    def run(self, eventid, message):
        ack = self._zbx.event.acknowledge(eventids=eventid, message=message)
        return ack

import requests

from lib.base import OpscenterAction


class StopNodeAction(OpscenterAction):
    def run(self, cluster_id, node_ip):
        url = self.get_full_url([cluster_id, 'ops', 'stop', node_ip])

        return requests.post(url).json()

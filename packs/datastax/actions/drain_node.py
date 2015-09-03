import requests

from lib.base import OpscenterAction


class DrainNodeAction(OpscenterAction):
    def run(self, cluster_id, node_ip):
        url = self.get_full_url([cluster_id, 'ops', 'drain', node_ip])

        return requests.get(url).json()

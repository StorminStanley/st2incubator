import requests

from lib.base import OpscenterAction


class RestartNodeAction(OpscenterAction):
    def run(self, cluster_id, node_ip):
        url = self.get_full_url([cluster_id, 'ops', 'restart', node_ip])

        return requests.post(url).json()

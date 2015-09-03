import requests

from lib.base import OpscenterAction


class GetNodeConfAction(OpscenterAction):

    def run(self, cluster_id, node_ip):
        url = self._get_full_url([cluster_id, 'nodeconf', node_ip])

        return requests.get(url).json()

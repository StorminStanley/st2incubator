import requests

from lib.base import OpscenterAction


class RestartClusterAction(OpscenterAction):
    def run(self, cluster_id):
        url = self.get_full_url([cluster_id, 'ops', 'restart'])

        return requests.post(url).json()

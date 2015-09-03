import requests

from lib.base import OpscenterAction


class StopClusterRepairAction(OpscenterAction):
    def run(self, cluster_id):
        url = self.get_full_url([cluster_id, 'services', 'repair'])

        return requests.delete(url).json()

import requests

from lib.base import OpscenterAction


class GetClusterRepairStatusAction(OpscenterAction):
    def run(self, cluster_id):
        url = self.get_full_url([cluster_id, 'services', 'repair'])

        return requests.get(url).json()

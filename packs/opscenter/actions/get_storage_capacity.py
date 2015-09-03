import requests

from lib.base import OpscenterAction


class GetStorageCapacity(OpscenterAction):

    def run(self, cluster_id):
        url = self._get_full_url([cluster_id, 'storage-capacity'])

        return requests.get(url).json()

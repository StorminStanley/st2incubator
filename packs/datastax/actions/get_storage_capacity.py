from urlparse import urljoin

import requests

from lib.base import OpscenterAction


class GetStorageCapacity(OpscenterAction):

    def run(self, cluster_id):
        url = urljoin(self._get_base_url(), cluster_id, 'storage-capacity')

        return requests.get(url).json()

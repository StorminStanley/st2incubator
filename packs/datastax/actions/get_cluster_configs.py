from urlparse import urljoin

import requests

from lib.base import OpscenterAction


class GetClustersAction(OpscenterAction):

    def run(self):
        url = urljoin(self._get_base_url(), 'cluster_configs')

        return requests.get(url).json()

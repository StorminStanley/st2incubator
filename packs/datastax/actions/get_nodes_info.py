from urlparse import urljoin

import requests

from lib.base import OpscenterAction


class GetNodesInfoAction(OpscenterAction):

    def run(self, cluster_id):
        url = urljoin(self._get_base_url(), cluster_id, 'nodes')

        return requests.get(url).json()

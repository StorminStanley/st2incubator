from urlparse import urljoin

import requests

from lib.base import OpscenterAction


class GetNodesInfoAction(OpscenterAction):

    def run(self, cluster_id, node_ip, node_property=None):
        url = urljoin(self._get_base_url(), cluster_id, 'nodes', 'node_ip')

        if node_property:
            url = urljoin(url, node_property)

        return requests.get(url).json()

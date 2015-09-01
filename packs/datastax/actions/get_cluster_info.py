from urlparse import urljoin

import requests

from lib.base import OpscenterAction


class GetClusterInfoAction(OpscenterAction):

    def run(self, cluster_id, cluster_property=None):
        url = urljoin(self._get_base_url(), cluster_id, 'cluster')

        if cluster_property:
            url = urljoin(url, cluster_property)

        return requests.get(url).json()

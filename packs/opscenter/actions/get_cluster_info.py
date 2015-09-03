import requests

from lib.base import OpscenterAction


class GetClusterInfoAction(OpscenterAction):

    def run(self, cluster_id, cluster_property=None):
        url_parts = [cluster_id, 'cluster']

        if cluster_property:
            url_parts.append(cluster_property)

        url = self._get_full_url(url_parts)

        return requests.get(url).json()

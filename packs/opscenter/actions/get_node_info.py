import requests

from lib.base import OpscenterAction


class GetNodesInfoAction(OpscenterAction):

    def run(self, cluster_id, node_ip, node_property=None):
        url_parts = [cluster_id, 'nodes', node_ip]

        if node_property:
            url_parts.append(node_property)

        url = self._get_full_url(url_parts)

        return requests.get(url).json()

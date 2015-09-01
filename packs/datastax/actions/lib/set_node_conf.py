from urlparse import urljoin

import requests

from lib.base import OpscenterAction


class GetNodeConfAction(OpscenterAction):

    def run(self, cluster_id, node_ip, node_conf):
        url = urljoin(self._get_base_url(), cluster_id, 'nodeconf', node_ip)

        return requests.post(url, data=node_conf).json()

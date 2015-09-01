from urlparse import urljoin

import requests
import yaml

from lib.base import OpscenterAction


class SetNodeConfAction(OpscenterAction):

    def run(self, cluster_id, node_ip, node_conf):
        url = urljoin(self._get_base_url(), cluster_id, 'nodeconf', node_ip)

        yaml.safe_loads(node_conf)  # If this throws, fail the action.

        return requests.post(url, data=node_conf).json()

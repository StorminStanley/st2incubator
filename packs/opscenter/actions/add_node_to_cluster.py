import json

import requests

from lib.base import OpscenterAction


class AddNodeToCluster(OpscenterAction):

    def run(self, node_config, cluster_id=None):
        if not cluster_id:
            cluster_id = self.cluster_id

        try:
            payload = json.loads(node_config)
        except:
            self.logger.error('Invalid config file. Not valid JSON string.')
            raise
        url = self._get_full_url([cluster_id, 'provision'])

        return requests.post(url, data=payload).json()

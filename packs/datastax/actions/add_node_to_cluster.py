import json

import requests

from lib.base import OpscenterAction


class AddNodeToCluster(OpscenterAction):

    def run(self, cluster_id, node_config):
        try:
            payload = json.loads(node_config)
        except:
            self.logger.error('Invalid config file. Not valid JSON string.')
            raise
        url = self.get_full_url([cluster_id, 'provision'])

        return requests.post(url, data=payload).json()

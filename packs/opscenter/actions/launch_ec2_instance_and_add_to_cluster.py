import json

import requests

from lib.base import OpscenterAction


class LaunchEC2NodeAndAddToCluster(OpscenterAction):

    def run(self, cluster_id, launch_config):
        try:
            payload = json.loads(launch_config)
            if 'provision' not in payload:
                raise Exception('"Provision" section missing in launch ' +
                                'config.')
            if 'launch' not in payload:
                raise Exception('"launch" section missing in launch config.')
        except:
            self.logger.error('Invalid config file. Not valid JSON string.')
            raise

        url = self.get_full_url([cluster_id, 'launch'])

        return requests.post(url, data=payload).json()

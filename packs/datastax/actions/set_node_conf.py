import requests
import yaml

from lib.base import OpscenterAction


class SetNodeConfAction(OpscenterAction):

    def run(self, cluster_id, node_ip, node_conf):
        try:
            yaml.safe_loads(node_conf)  # If this throws, fail the action.
        except:
            self.logger.error('Configuration is not valid YAML.')
            raise
        url = self._get_full_url([cluster_id, 'nodeconf', node_ip])

        return requests.post(url, data=node_conf).json()

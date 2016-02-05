from pyzabbix import ZabbixAPI

__all__ = [
    'BaseZabbixAction'
]


class Action(object):
    def __init__(self, config):
        self.config = config


class BaseZabbixAction(Action):
    def __init__(self, config):
        super(BaseZabbixAction, self).__init__(config=config)
        self._zbx = self._get_zbx()

    def _get_zbx(self):
        config = self.config

        zabbix_api = config['zabbix_url']
        usename = config['user']
        password = config['password']
        zbx = ZabbixAPI(zabbix_api)
        zbx.login(usename, password)
        return zbx

    def _get_file_content(self, file_path):
        with open(file_path, 'r') as fp:
            content = fp.read()

        return content

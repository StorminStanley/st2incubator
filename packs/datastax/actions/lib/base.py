from st2actions.runners.pythonrunner import Action


class OpscenterAction(Action):

    def _get_base_url(self):
        return self.config['opscenter_base_url']

    def _get_auth_creds(self):
        pass

from urlparse import urljoin

from st2actions.runners.pythonrunner import Action


class OpscenterAction(Action):

    def _get_base_url(self):
        return self.config.get('opscenter_base_url', None)

    def _get_auth_creds(self):
        pass

    def _get_full_url(url_parts):
        base = 'http://localhost:8888/v1'

        if not url_parts:
            return base

        parts = [base]
        parts.extend(url_parts)

        def urljoin_sane(url1, url2):
            if url1.endswith('/'):
                return urljoin(url1, url2)
            else:
                return urljoin(url1 + '/', url2)

        return reduce(urljoin_sane, parts)

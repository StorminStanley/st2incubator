import urllib
import httplib
import requests

from st2actions.runners.pythonrunner import Action

__all__ = [
    'TypeformAction'
]


class TypeformAction(Action):

    def run(self, form_id, api_key, completed=True):
        api_key = api_key if api_key else self.config['api_key']
        completed = str(completed).lower()
        url = "https://api.typeform.com/v0/form/%s?key=%s&completed=%s" % \
            (form_id, api_key, completed)

        headers = {}
        headers['Content-Type'] = 'application/x-www-form-urlencoded'

        params = {"key": api_key,
                  "completed": completed
                  }

        data = urllib.urlencode(params)
        self.logger.info(data)
        response = requests.get(url=url,
                                headers=headers, params=data)

        if response.status_code == httplib.OK:
            return response.json()
        else:
            failure_reason = ('Failed to retrieve registrations: %s \
                (status code: %s)' %
                              (response.text, response.status_code))
            self.logger.exception(failure_reason)
            raise Exception(failure_reason)

        return True

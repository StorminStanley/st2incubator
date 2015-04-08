import json
import httplib
import requests

from st2actions.runners.pythonrunner import Action

__all__ = [
    'PostMessageAction'
]

class PostMessageAction(Action):
    def run(self, message, channel, user=None, whisper=False):
        endpoint = self.config['endpoint']

        headers = {}
        headers['Content-Type'] = 'application/json'
        body = {
            'channel': channel,
            'message': message
        }

        if user:
            body['user'] = user

        if whisper == True:
            body['whisper'] = whisper

        data = json.dumps(body)
        response = requests.post(url=endpoint, headers=headers, data=data)

        if response.status_code == httplib.OK:
            self.logger.info('Message successfully posted')
        else:
            self.logger.exception('Failed to post message: %s' % (response.text))

        return True

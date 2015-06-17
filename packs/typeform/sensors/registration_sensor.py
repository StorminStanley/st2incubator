# Requirements:
# See ../requirements.txt
# import datetime

import httplib
import requests
import MySQLdb
import MySQLdb.cursors

from st2reactor.sensor.base import PollingSensor

BASE_URL = 'https://api.typeform.com/v0/form'
EMAIL_FIELD = "email_7723200"
FIRST_NAME_FIELD = "textfield_7723291"
LAST_NAME_FIELD = "textfield_7723236"
SOURCE_FIELD = "textarea_7723206"
NEWSLETTER_FIELD = "yesno_7723486"


class TypeformRegistrationSensor(PollingSensor):
    def __init__(self, sensor_service, config=None, poll_interval=5):
        super(TypeformRegistrationSensor, self).__init__(
            sensor_service=sensor_service,
            config=config,
            poll_interval=poll_interval)
        self._trigger_pack = 'typeform'
        self._trigger_ref = '.'.join([self._trigger_pack, 'registration'])

        self.db = self._conn_db(host=self.config['db_host'],
                                user=self.config['db_user'],
                                passwd=self.config['db_pass'],
                                db=self.config['db_name'])

        self.url = self._get_url(self.config['form_id'],
                                 self.config['api_key'],
                                 self.config['completed'])

    def setup(self):
        pass

    def poll(self):
        registration = {}
        api_registration_list = self._get_api_registrations()

        for registration in api_registration_list['responses']:
            user = registration['answers']
            if self._check_db_registrations(user[EMAIL_FIELD]) is False:
                registration['email'] = user[EMAIL_FIELD]
                registration['first_name'] = user[FIRST_NAME_FIELD]
                registration['last_name'] = user[LAST_NAME_FIELD]
                registration['source'] = user[SOURCE_FIELD]
                registration['newsletter'] = user[NEWSLETTER_FIELD]

                self._dispatch_trigger(self._trigger_ref, data=registration)

    def _get_api_registrations(self):
        headers = {}
        headers['Content-Type'] = 'application/x-www-form-urlencoded'

        response = requests.get(url=self.url, headers=headers)

        if response.status_code == httplib.OK:
            return response.json()
        else:
            failure_reason = ('Failed to retrieve registrations: %s \
                (status code: %s)' %
                              (response.text, response.status_code))
            self.logger.exception(failure_reason)
            raise Exception(failure_reason)

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        pass

    def update_trigger(self, trigger):
        pass

    def remove_trigger(self, trigger):
        pass

    def _dispatch_trigger(self, trigger, data):
        self._sensor_service.dispatch(trigger, data)

    def _get_url(self, form_id, api_key, completed):
        return "%s/%s?key=%s&completed=%s" % \
            (BASE_URL, form_id, api_key, completed)

    def _check_db_registrations(self, email):
        c = self.db.cursor()

        results = c.execute('SELECT * FROM user_registration WHERE \
            email="%s"' % email)

        if results.fetchone():
            return True

        return False

    def _conn_db(self, host, user, passwd, db):
        return MySQLdb.connect(host=host,
                               user=user,
                               passwd=passwd,
                               db=db,
                               cursorclass=MySQLdb.cursors.DictCursor)

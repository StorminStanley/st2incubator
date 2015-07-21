# Requirements:
# See ../requirements.txt

import httplib
import MySQLdb
import MySQLdb.cursors
import requests
import urllib
import urlparse

from st2reactor.sensor.base import PollingSensor

BASE_URL = 'https://api.typeform.com/v0/form/'
EMAIL_FIELD = "email_7723200"
FIRST_NAME_FIELD = "textfield_7723291"
LAST_NAME_FIELD = "textfield_7723236"
SOURCE_FIELD = "textarea_7723206"
NEWSLETTER_FIELD = "yesno_7723486"
REFERER_FIELD = "referer"
DATE_LAND_FIELD = "date_land"
DATE_SUBMIT_FIELD = "date_submit"


class TypeformRegistrationSensor(PollingSensor):
    def __init__(self, sensor_service, config=None, poll_interval=180):
        super(TypeformRegistrationSensor, self).__init__(
            sensor_service=sensor_service,
            config=config,
            poll_interval=poll_interval)

        self.logger = self._sensor_service.get_logger(
            name=self.__class__.__name__)
        self._trigger_pack = 'typeform'
        self._trigger_ref = '.'.join([self._trigger_pack, 'registration'])

        self.sensor_config = self._config.get('sensor', False)
        db_config = self._config.get('mysql', False)
        self.db = self._conn_db(host=db_config.get('host', None),
                                user=db_config.get('user', None),
                                passwd=db_config.get('pass', None),
                                db=db_config.get('name', None))

        self.request_data = {"key": self._config.get('api_key', None),
                             "completed": str(self._config.get('completed',
                                                               True)).lower()}

        self.url = self._get_url(self._config.get('form_id', None))
        self.retries = self._config.get('retries', 3)

    def setup(self):
        pass

    def poll(self):
        registration = {}
        api_registration_list = self._get_api_registrations(self.request_data)

        for r in api_registration_list.get('responses', None):
            user = r.get('answers', None)
            meta = r.get('metadata', None)
            if self._check_new_registration(user.get(EMAIL_FIELD, False)):
                registration['email'] = user.get(EMAIL_FIELD, None)
                registration['first_name'] = user.get(FIRST_NAME_FIELD, None)
                registration['last_name'] = user.get(LAST_NAME_FIELD, None)
                registration['source'] = user.get(SOURCE_FIELD, None)
                registration['newsletter'] = user.get(NEWSLETTER_FIELD, None)
                registration['referer'] = meta.get(REFERER_FIELD, None)
                registration['date_land'] = meta.get(DATE_LAND_FIELD, None)
                registration['date_submit'] = meta.get(DATE_SUBMIT_FIELD, None)

                self._dispatch_trigger(self._trigger_ref, data=registration)

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

    def _get_url(self, endpoint):
        url = urlparse.urljoin(BASE_URL, endpoint)

        return url

    def _get_api_registrations(self, params):
        data = urllib.urlencode(params)
        headers = {}
        headers['Content-Type'] = 'application/x-www-form-urlencoded'

        for x in range(self.sensor_config.retries):
            try:
                response = requests.request(method='GET',
                                            url=self.url,
                                            headers=headers,
                                            timeout=self.sensor_config.timeout,
                                            params=data)
            except Exception, e:
                self.logger.info(e)

        if not response.text:
            raise Exception('Failed to connect to TypeForm API.')

        if response.status_code != httplib.OK:
            failure_reason = ('Failed to retrieve registrations: %s \
                (status code: %s)' % (response.text, response.status_code))
            self.logger.info(failure_reason)
            raise Exception(failure_reason)

        return response.json()

    def _check_new_registration(self, email):
        email = MySQLdb.escape_string(email)
        c = self.db.cursor()
        query = 'SELECT * FROM user_registration WHERE email="%s"' % email
        try:
            c.execute(query)
            self.db.commit()
        except MySQLdb.Error, e:
            self.logger.info(str(e))
            return False

        row = c.fetchone()
        c.close()

        if row:
            return False

        self.logger.info("%s is not a currently registered user." % email)
        return True

    def _conn_db(self, host, user, passwd, db):
        return MySQLdb.connect(host=host,
                               user=user,
                               passwd=passwd,
                               db=db,
                               cursorclass=MySQLdb.cursors.DictCursor)

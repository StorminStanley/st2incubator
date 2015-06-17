# Requirements:
# See ../requirements.txt

import httplib
import requests
import urlparse
import urllib
import MySQLdb
import MySQLdb.cursors

from st2reactor.sensor.base import PollingSensor

BASE_URL = 'https://api.typeform.com/v0/form'
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

        self._trigger_pack = 'typeform'
        self._trigger_ref = '.'.join([self._trigger_pack, 'registration'])

        db_config = self._config.get('mysql', False)
        self.db = self._conn_db(host=db_config.get('host', None),
                                user=db_config.get('db_user', None),
                                passwd=db_config.get('db_pass', None),
                                db=db_config.get('db_name', None))

        self.url = self._get_url(self._config.get('form_id', None),
                                 self._config.get('api_key', None),
                                 self._config.get('completed', None))

    def setup(self):
        pass

    def poll(self):
        registration = {}
        api_registration_list = self._get_api_registrations()

        for r in api_registration_list.get('responses', None):
            user = r.get('answers', None)
            meta = r.get('metadata', None)
            if not self._check_db_registrations(user.get(EMAIL_FIELD, False)):
                registration['email'] = user.get(EMAIL_FIELD, None)
                registration['first_name'] = user.get(FIRST_NAME_FIELD, None)
                registration['last_name'] = user.get(LAST_NAME_FIELD, None)
                registration['source'] = user.get(SOURCE_FIELD, None)
                registration['newsletter'] = user.get(NEWSLETTER_FIELD, None)
                registration['referer'] = meta.get(REFERER_FIELD, None)
                registration['date_land'] = meta.get(DATE_LAND_FIELD, None)
                registration['date_submit'] = meta.get(DATE_SUBMIT_FIELD, None)

                self._dispatch_trigger(self._trigger_ref, data=registration)

    def _get_api_registrations(self):
        headers = {}
        headers['Content-Type'] = 'application/x-www-form-urlencoded'

        response = requests.get(url=self.url, headers=headers)

        if response.status_code == httplib.OK:
            return response.json()
        else:
            failure_reason = ('Failed to retrieve registrations: %s \
                (status code: %s)' % (response.text, response.status_code))
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
        url = urlparse.urljoin(BASE_URL, "%s?key=%s&completed=%s" %
                               (form_id, api_key, str(completed).lower()))
        return url

    def _check_db_registrations(self, email):
        c = self.db.cursor()
        query = 'SELECT * FROM user_registration WHERE email="%s"' % email
        try:
            c.execute(query)
        except MySQLdb.Error, e:
            print str(e)
            return False

        if c.fetchone():
            return True

        return False

    def _conn_db(self, host, user, passwd, db):
        return MySQLdb.connect(host=host,
                               user=user,
                               passwd=passwd,
                               db=db,
                               cursorclass=MySQLdb.cursors.DictCursor)

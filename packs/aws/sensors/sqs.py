
import time

import boto3
from boto3.session import Session
from botocore.exceptions import ClientError

import json

from st2reactor.sensor.base import PollingSensor

class AWSSQSSensor(PollingSensor):
    """
    * self._sensor_service
        - provides utilities like
            get_logger() for writing to logs.
            dispatch() for dispatching triggers into the system.
    * self._config
        - contains configuration that was specified as
          config.yaml in the pack.
    * self._poll_interval
        - indicates the interval between two successive poll() calls.
    """
    def __init__(self, sensor_service, config=None, poll_interval=5):
        super(AWSSQSSensor, self).__init__(sensor_service=sensor_service, config=config,
                                           poll_interval=poll_interval)

    def setup(self):
        self.input_queue = self._config['setup']['input_queue']
        self.aws_access_key = self._config['setup']['aws_access_key_id']
        self.aws_secret_key = self._config['setup']['aws_secret_access_key']
        self.aws_region = self._config['setup']['region']
        self._logger = self._sensor_service.get_logger(name=self.__class__.__name__)

        self.session = None
        self.sqs_res = None

        self._SetupSqs()
        self.queue = self._GetQueueByName(self.input_queue)

    def poll(self):
        msg = self._receive_messages(queue=self.queue)
        if msg:
            payload = {"queue": self.input_queue, "body": msg[0].body}
            self._sensor_service.dispatch(trigger="aws.sqs_new_message", payload=payload)
            msg[0].delete()

    def cleanup(self):
        pass

    def add_trigger(self, trigger):
        # This method is called when trigger is created
        pass

    def update_trigger(self, trigger):
        # This method is called when trigger is updated
        pass

    def remove_trigger(self, trigger):
        pass

    def _SetupSqs(self):
        ''' Setup Boto3 structures '''
        self._logger.debug('Setting up SQS resources')
        self.session = Session(aws_access_key_id=self.aws_access_key,
                               aws_secret_access_key=self.aws_secret_key,
                               region_name=self.aws_region)

        self.sqs_res = self.session.resource('sqs')

    def _GetQueueByName(self, queueName):
        ''' Fetch QUEUE by it's name create new one if queue doesn't exist '''
        try:
            queue = self.sqs_res.get_queue_by_name(QueueName=queueName)
        except ClientError as e:
            self._logger.warning("SQS Queue: %s doesn't exist, creating it.", queueName)
            if e.response['Error']['Code'] == 'AWS.SimpleQueueService.NonExistentQueue':
                queue = self.sqs_res.create_queue(QueueName=queueName)
            else:
                raise

        return queue

    def _receive_messages(self, queue, wait_time=2, num_messages=1):
        ''' Receive a message from queue and return it. '''
        msg = queue.receive_messages(WaitTimeSeconds=wait_time, MaxNumberOfMessages=num_messages)

        return msg

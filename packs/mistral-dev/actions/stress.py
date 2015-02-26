import copy
import eventlet

from st2actions.runners import pythonrunner
from st2client import client
from st2client import models


DONE_STATES = ['succeeded', 'failed']


class StressAction(pythonrunner.Action):

    def __init__(self, config=None):
        super(TestMockLoadAction, self).__init__(config)
        self.st2client = client.Client()

    def run(self, prefix, total, batch_size):
        i = 0
        while i < total:
            j = i + batch_size
            if j > total:
                j = total
            self._run_batch(prefix, i, j, len(str(total)))
            i = j

    def _run_batch(self, prefix, start, end, fill):
        # 60 * 10 = 600 sec = 10 min
        current, count = 0, 60
        executions = [self._execute(prefix + str(i + 1).zfill(fill)) for i in range(start, end)]
        while len([e for e in executions if e.status not in DONE_STATES]) > 0:
            executions = [self.st2client.liveactions.get_by_ref_or_id(e.id) for e in executions]
            current = current + 1
            if current >= count:
                raise Exception('Timed out waiting for batch to complete.')
            eventlet.sleep(10)

    def _execute(self, vm_name):
        execution = models.LiveAction()
        execution.action = 'examples.mistral-workbook-complex'
        execution.parameters = { 'vm_name': vm_name }
        return self.st2client.liveactions.create(execution)

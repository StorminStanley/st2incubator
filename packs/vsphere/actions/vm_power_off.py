import eventlet

from pyVmomi import vim

from vmwarelib import inventory
from vmwarelib.actions import BaseAction


class VMPowerOff(BaseAction):

    def run(self, vm_id):
        # convert ids to stubs
        vm = inventory.get_virtualmachine(self.service_instance, moid=vm_id)
        task = vm.PowerOffVM_Task()
        while task.info.state == vim.TaskInfo.State.running:
            eventlet.sleep(1)
        return task.info.state == vim.TaskInfo.State.success

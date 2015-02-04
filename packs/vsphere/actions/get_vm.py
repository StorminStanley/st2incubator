from pyVmomi import vim

from vmwarelib import inventory
from vmwarelib.actions import BaseAction

class GetVM(BaseAction):

    def run(self, id=None, name=None, datastore=None, datastore_cluster=None, resource_pool=None, vapp=None, host=None, folder=None, cluster=None, datacenter=None, virtual_switch=None, no_recursion=False ):
        #TODO: food for thought. PowerCli contains additional parameters that are not present here for the folliwing reason:
        #<server> - we may need to bring it in if we decide to have connections to more than 1 VC.
        #<tag>    - Tags in VC are not the same as tags you see in Web Client for the reason, that those tags are stored in Inventory Service only. PowerCli somehow can access it, from vSphere SDK there is no way.

        si = self.si
        si_content = si.RetrieveContent()
        props = ['name', 'runtime.powerState']
        result = []
        moid_to_vm = {}

        vms_from_vmids = []
        if id:
            vm_moids = [moid.strip() for moid in id.split(',')]
            vms_from_vmids = [vim.VirtualMachine(moid, stub=si._stub) for moid in vm_moids]
            GetVM.__add_vm_properties_to_map_from_vm_array(moid_to_vm, vms_from_vmids)

        #getting vms from datastore objects
        vms_from_datastores = []
        if datastore:
            datastore_moids = [moid.strip() for moid in datastore.split(',')]
            datastores = [vim.Datastore(moid, stub=si._stub) for moid in datastore_moids]
            for ds in datastores:
                vms_from_datastores.extend(ds.vm)
            GetVM.__add_vm_properties_to_map_from_vm_array(moid_to_vm, vms_from_datastores)

        #getting vms from datastore cluster objects
        vms_from_datastore_clusters = []
        if datastore_cluster:
            datastore_cluster_moids = [moid.strip() for moid in datastore_cluster.split(',')]
            datastore_clusters = [vim.StoragePod(moid, stub=si._stub) for moid in datastore_cluster_moids]
            for ds_cl in datastore_clusters:
                for ds in ds_cl.childEntity:
                  vms_from_datastore_clusters.extend(ds.vm)
            GetVM.__add_vm_properties_to_map_from_vm_array(moid_to_vm, vms_from_datastore_clusters)

        #getting vms from virtual switch objects
        vms_from_virtual_switches = []
        if virtual_switch:
            virtual_switch_moids = [moid.strip() for moid in virtual_switch.split(',')]
            virtual_switches = [vim.DistributedVirtualSwitch(moid, stub=si._stub) for moid in virtual_switch_moids]
            for vswitch in virtual_switches:
                for pg in vswitch.portgroup:
                  vms_from_virtual_switches.extend(pg.vm)
            GetVM.__add_vm_properties_to_map_from_vm_array(moid_to_vm, vms_from_virtual_switches)

        #getting vms from containers (location param)
        vms_from_containers = []
        containers = []

        if resource_pool:
            container_moids = [moid.strip() for moid in resource_pool.split(',')]
            containers += [vim.ResourcePool(moid, stub=si._stub) for moid in container_moids]

        if vapp:
            container_moids = [moid.strip() for moid in vapp.split(',')]
            containers += [vim.VirtualApp(moid, stub=si._stub) for moid in container_moids]

        if host:
            container_moids = [moid.strip() for moid in host.split(',')]
            containers += [vim.HostSystem(moid, stub=si._stub) for moid in container_moids]

        if folder:
            container_moids = [moid.strip() for moid in folder.split(',')]
            containers += [vim.Folder(moid, stub=si._stub) for moid in container_moids]

        if cluster:
            container_moids = [moid.strip() for moid in cluster.split(',')]
            containers += [vim.ComputeResource(moid, stub=si._stub) for moid in container_moids]

        if datacenter:
            container_moids = [moid.strip() for moid in datacenter.split(',')]
            containers += [vim.Datacenter(moid, stub=si._stub) for moid in container_moids]

        for cont in containers:
            objView = si_content.viewManager.CreateContainerView(cont, [vim.VirtualMachine], not no_recursion)
            tSpec = vim.PropertyCollector.TraversalSpec(name='tSpecName', path='view', skip=False, type=vim.view.ContainerView)
            pSpec = vim.PropertyCollector.PropertySpec(all=False, pathSet=props, type=vim.VirtualMachine)
            oSpec = vim.PropertyCollector.ObjectSpec(obj=objView, selectSet=[tSpec], skip=False)
            pfSpec = vim.PropertyCollector.FilterSpec(objectSet=[oSpec], propSet=[pSpec], reportMissingObjectsInResults=False)
            retOptions = vim.PropertyCollector.RetrieveOptions()
            retProps = si_content.propertyCollector.RetrievePropertiesEx(specSet=[pfSpec], options=retOptions)
            vms_from_containers += retProps.objects
            while retProps.token:
                retProps = si_content.propertyCollector.ContinueRetrievePropertiesEx(token=retProps.token)
                vms_from_containers += retProps.objects
            objView.Destroy()

        for vm in vms_from_containers:
            if vm.obj._GetMoId() not in moid_to_vm:
                moid_to_vm[vm.obj._GetMoId()] = {
                    "moid": vm.obj._GetMoId(),
                    "name": vm.propSet[0].val,
                    "runtime.powerState": vm.propSet[1].val
                }

        return moid_to_vm.values()

    @staticmethod
    def __add_vm_properties_to_map_from_vm_array(vm_map, vm_array):
        for vm in vm_array:
            if vm._GetMoId() not in vm_map:
                vm_map[vm._GetMoId()] = {
                      "moid": vm._GetMoId(),
                      "name": vm.name,
                      "runtime.powerState": vm.runtime.powerState
                      }

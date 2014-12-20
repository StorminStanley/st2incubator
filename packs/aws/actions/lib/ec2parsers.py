#!/usr/bin/env python

import boto.ec2

class FieldLists():
    ADDRESS = ['public_ip','instance_id','domain','allocation_id','association_id','network_interface_id','network_interface_owner_id','private_ip_address']
    INSTANCE = ['id','public_dns_name','private_dns_name','state','state_code','previous_state','previous_state_code','key_name','instance_type','launch_time','image_id','placement','placement_group','placement_tenancy','kernel','ramdisk','architecture','hypervisor','virtualization_type','ami_launch_index','monitored','monitoring_state','spot_instance_request_id','subnet_id','vpc_id','private_ip_address','ip_address','platform','root_device_name','root_device_type','state_reason','ebs_optimized']
    VOLUME = ['id','create_time','status','size','snapshot_id','zone','type','iops','encrypted']
    ZONE = ['name', 'state', 'region_name', 'messages']


class ResultSets(object):

    def __init__(self):
        self.foo = ""

    def selector(self,output):
        formatted = []
        if isinstance(output, boto.ec2.instance.Reservation):
            return self.parseReservation(output)
        elif isinstance(output, boto.ec2.instance.Instance):
            return self.parseInstance(output)
        elif isinstance(output, boto.ec2.volume.Volume):
            return self.parseVolume(output)
        elif isinstance(output, boto.ec2.zone.Zone):
            return self.parseZone(output)
        elif isinstance(output, boto.ec2.address.Address):
            return self.parseAddress(output)
        else:
            return output

    def formatter(self,output):
        formatted = []
        if isinstance(output,list):
            for o in output:
                formatted.append(self.selector(o))
        else:
            formatted.append(self.selector(output))
        return formatted

    def parseReservation(self,output):
        instance_list = []
        for instance in output.instances:
            instance_data = self.parseInstance(instance)
            instance_data['owner_id'] = output.owner_id
            instance_list.append(instance_data)
        return instance_list

    def parseAddress(self,output):
        instance_data = {field: getattr(output, field) for field in FieldLists.ADDRESS}
        return instance_data

    def parseInstance(self,output):
        instance_data = {field: getattr(output, field) for field in FieldLists.INSTANCE}
        return instance_data

    def parseVolume(self,output):
        volume_data = {field: getattr(output, field) for field in FieldLists.VOLUME}
        return volume_data

    def parseZone(self,output):
        volume_data = {field: getattr(output, field) for field in FieldLists.ZONE}
        return volume_data

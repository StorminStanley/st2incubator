#!/usr/bin/env python

import boto.ec2

class FieldLists():
    INSTANCE = ['id','public_dns_name','private_dns_name','state','state_code','previous_state','previous_state_code','key_name','instance_type','launch_time','image_id','placement','placement_group','placement_tenancy','kernel','ramdisk','architecture','hypervisor','virtualization_type','ami_launch_index','monitored','monitoring_state','spot_instance_request_id','subnet_id','vpc_id','private_ip_address','ip_address','platform','root_device_name','root_device_type','state_reason','ebs_optimized']


class ResultSets(object):

    def __init__(self):
        self.foo = ""

    def formatter(self,output):
        formatted = []
        if isinstance(output, boto.ec2.instance.Reservation):
            return self.parseReservation(output)
        else:
            return output

    def parseReservation(self,output):
        instance_list = []
        for instance in output.instances:
            instance_data = {field: getattr(instance, field) for field in FieldLists.INSTANCE}
            instance_list.append(instance_data)
        return instance_list

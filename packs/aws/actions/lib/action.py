import boto.ec2
import boto.route53
import imp, re, importlib
from st2actions.runners.pythonrunner import Action
import os, yaml, json, time
from ec2parsers import ResultSets

class BaseAction(Action):

    def __init__(self, config):
        super(BaseAction, self).__init__(config)
        if config['st2_user_data'] is not "":
            self.userdata = open(config['st2_user_data'],'r').read()
        else:
            self.userdata = None
        self.setup = config['setup']
        self.resultsets = ResultSets()

    def ec2_connect(self):
        region = self.setup['region']
        del self.setup['region']
        return boto.ec2.connect_to_region(region,**self.setup)

    def r53_connect(self):
        del self.setup['region']
        return boto.route53.connection.Route53Connection(**self.setup)

    def get_r53zone(self,zone):
        conn = self.r53_connect()
        return conn.get_zone(zone)

    def st2_user_data(self):
        return self.userdata
        
    def wait_for_state(self, instance_id, state):
        state_list = {}
        obj = self.ec2_connect()
        time.sleep(3)
        for instance in obj.get_only_instances([instance_id,]):
            try:
                current_state = instance.update()
            except Exception, e:
                self.logger.info("Instance (%s) not listed. Error: %s" % (instance_id,e))
                time.sleep(3)
            while current_state != state:
                current_state = instance.update()
            state_list[instance_id] = current_state
        return state_list

    def do_method(self,module_path, cls, action,**kwargs):
      results = {}
      module = importlib.import_module(module_path)
      # hack to connect to correct region
      if cls == 'EC2Connection':
          obj = self.ec2_connect()
      elif module_path == 'boto.route53.zone' and cls == 'Zone':
          zone = kwargs['zone']
          del kwargs['zone']
          obj = self.get_r53zone(zone)
      else:
          if cls == 'Route53Connection':
              del self.setup['region']
          obj = getattr(module,cls)(**self.setup)
      resultset = getattr(obj,action)(**kwargs)
      return self.resultsets.formatter(resultset)

    def do_function(self,module_path,action,**kwargs):
      module = __import__(module_path)
      return getattr(module,action)(**kwargs)

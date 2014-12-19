import boto.ec2
import imp, re, importlib
from st2actions.runners.pythonrunner import Action
import os, yaml, json, time
from ec2parsers import ResultSets

class BaseAction(Action):

    def __init__(self, config):
        super(BaseAction, self).__init__(config)
        self.userdata = open(config['st2_user_data'],'r').read()
        self.setup = config['setup']
        self.resultsets = ResultSets()

    def ec2_connect(self):
        region = self.setup['region']
        del self.setup['region']
        return boto.ec2.connect_to_region(region,**self.setup)

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
      else:
          obj = getattr(module,cls)(**self.setup)
      resultset = getattr(obj,action)(**kwargs)
      return self.resultsets.formatter(resultset)

    def do_function(self,module_path,action,**kwargs):
      module = __import__(module_path)
      return getattr(module,action)(**kwargs)

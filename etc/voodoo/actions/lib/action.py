import imp, re, importlib
from st2actions.runners.pythonrunner import Action
import os, yaml

class BaseAction(Action):

    def __init__(self, config):
        super(BaseAction, self).__init__(config)
        if 'setup' in config.keys():
            self.setup = config['setup']

    def do_method(self,module_path, cls, action,**kwargs):
      module = importlib.import_module(module_path)
      obj = getattr(module,cls)(**self.setup)
      return getattr(obj,action)(**kwargs)

    def do_function(self,module_path,action,**kwargs):
      module = __import__(module_path)
      return getattr(module,action)(**kwargs)

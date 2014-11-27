from lib import ec2
from st2actions.runners.pythonrunner import Action


class BaseAction(Action):

    def __init__(self, config):
        super(BaseAction, self).__init__(config)
        self.ec2 = ec2.EC2(config)
    
    def ec2_action(self,action,**kwargs):
      act = self.ec2.get_object(action)
      return act(self.ec2.conn,**kwargs)

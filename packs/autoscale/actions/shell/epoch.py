import time
from st2actions.runners.pythonrunner import Action

class Epoch(Action):
    def run(self):
        return int(round(time.time()))

import random
from st2actions.runners.pythonrunner import Action

class Splay(Action):
    def run(self):
        return random.randint(10,20)

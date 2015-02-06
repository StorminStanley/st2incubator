from st2actions.runners.pythonrunner import Action

class AsgEvalEventAction(Action):
    def run(self, current_time, last_event, delay):
        if ((last_event + (delay * 60)) < current_time):
            return True
        else:
            return False

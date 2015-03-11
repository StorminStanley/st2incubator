from st2actions.runners.pythonrunner import Action

class Merge(Action):
    def run(self, defaults, overrides):
        return dict(defaults.items() + overrides.items())

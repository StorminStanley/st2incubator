from lib import action

class LibratoSubmitCounter(action.LibratoBaseAction):
    def run(self, name, value, description=""):
        librato.submit(name, value, type='counter', description)

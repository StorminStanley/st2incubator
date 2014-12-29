from lib import action

class LibratoSubmitGauge(action.LibratoBaseAction):
    def run(self, name, value, description=""):
        librato.submit(name, value, description)

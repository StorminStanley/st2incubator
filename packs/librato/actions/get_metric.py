from lib import action

class LibratoGetMetric(action.LibratoBaseAction):
    def run(self, name, count=1, resolution=1):
        librato.get(name, count, resolution)

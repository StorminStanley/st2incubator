from lib import action

class LibratoDeleteMetric(action.LibratoBaseAction):
    def run(self, name):
        librato.delete(name)


from lib import action

class ConsulQueryServiceAction(action.ConsulBaseAction):
    def run(self, service):
        index, service = self.consul.catalog.service(service)
        return service

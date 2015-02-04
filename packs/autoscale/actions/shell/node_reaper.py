from st2actions.runners.pythonrunner import Action

class NodeReaperAction(Action):
    def run(self, nodes, count):
        hostlist = []
        for node in nodes:
            if 'id' in host:
                hostlist.append('id')

        if count == 0:
            return hostlist
        else:
            return hostlist[:count]

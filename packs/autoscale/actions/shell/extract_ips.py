from st2actions.runners.pythonrunner import Action

class ExtractIPs(Action):
    def run(self, nodes, count):
        ips = []
        for node in nodes:
            ips.append(node['public_ip'][1])

        if count:
            return ips[0:count]
        else:
            return ips

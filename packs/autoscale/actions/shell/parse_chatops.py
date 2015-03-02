from st2actions.runners.pythonrunner import Action

class ParseChatops(Action):
    def run(self, message):
        """
        Parses a passed string and attempts to separate command tree from arguments
        Expects: !XXX YYY ZZZ key=value key1=value1
        Returns: {'command': ['!XXX', 'YYY', 'ZZZ'], 'parameters': {'key': 'value', 'key1': 'value1'}}
        """
        command = []
        parameters = {}
        for i in message.split(' '):
            if "=" in i:
                kv = i.split('=')
                parameters[kv[0]]=kv[1]
            else:
                # Make sure to ignore any dangling commands after parameters begin
                if parameters == {}:
                    command.append(i)
        payload = {
            'command': command,
            'parameters': parameters,
        }
        return payload

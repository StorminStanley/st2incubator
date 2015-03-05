import re
from st2actions.runners.pythonrunner import Action

class ParseChatops(Action):
    def run(self, message):
        """
        Parses a passed string and attempts to separate command tree from arguments
        Expects: !XXX YYY ZZZ key=value key1=value1 key2='value with spaces'
        Returns: {
                  'command': ['!XXX', 'YYY', 'ZZZ'],
                  'parameters': {'key': 'value', 'key1': 'value1', 'key2': 'value with spaces'}
                 }
        """
        command = []
        parameters = {}
        search = re.compile('((\w+=[\'"][-\.\w\s]+[\'"])|(\w+=[-\.\w]+)|([-\.\w]+))')
        matches = re.findall(search, message)
        for match in matches:
            # Get rid of duplicates in the regex match
            s = list(set(match))
            # and then filter out any non-matches that appear as empty string
            expression = [i for i in s if i != '']

            for m in expression:
                # See if they look as if they are a K/V expression
                if "=" in m:
                    kv = m.split('=')
                    # Filter out any quotations coming from raw message, but keep aligned with key
                    parameters[kv[0]]=re.sub('[\'"]', '', kv[1])
                else:
                    # Make sure to ignore any dangling commands after parameters begin
                    if parameters == {}:
                        command.append(m)

        payload = {
            'command': command,
            'parameters': parameters,
        }
        return payload

from st2actions.runners.pythonrunner import Action
import json

class ParseJson(Action):
    def run(self, string):
        try:
            return json.loads(string)
        except (ValueError, KeyError, TypeError):
            print "JSON format error"

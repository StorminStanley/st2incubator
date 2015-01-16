from st2actions.runners.pythonrunner import Action

class ResultsAction(Action):

    def run(self,results,fields,max_failures=0):

        if fields is not None:
            return { k: results[k] for k in fields }
        else:
            return results

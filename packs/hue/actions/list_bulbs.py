from lib import action

class ListBulbsAction(action.BaseAction):
    def run(self, name):
        bulbs = {}
        lights = self.hue.lights

        for light_id, light in lights:
            bulbs[light_id] = light.state['name']

        return bulbs

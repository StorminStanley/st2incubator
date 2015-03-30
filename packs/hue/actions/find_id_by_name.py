from lib import action

class FindIDByNameAction(action.BaseAction):
    def run(self, name):
        lights = self.hue.lights
        for light_id, light in lights:
            if light.state['name'] == name:
                return light_id
            else:
                error_msg = "Unknown Bulb"
                return error_msg

import re

from st2actions.runners.pythonrunner import Action


REGEX_PATTERN = '^([0-9A-Fa-f]+)$'


class ExtractAction(Action):
    def run(self, text):
        words = [word for word in text.split(' ') if len(word) >= 32]

        for word in words:
            if re.search(REGEX_PATTERN, word):
                return word

        return None

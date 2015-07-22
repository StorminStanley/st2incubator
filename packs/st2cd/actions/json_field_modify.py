#!/usr/bin/env python

import argparse
import json
import os


def modify_json_field_and_save(file_path, field, value):
    """
    Loads JSON file from disk, looks for field and modifies field's
    value to given value.

    :param file_path: Absolute path to JSON file.
    :type file_path: ``str``

    :param field: Name of the field to modify.
    :type field: ``str``

    :param value: Value to replace with.
    :type value: ``str`` or ``int`` or ``boolean`` or ``object``
    """

    if not os.path.exists(file_path):
        raise Exception('File %s not found.' % file_path)

    json_doc = None
    with open(file_path, 'r') as json_file:
        json_doc = json.load(json_file)
        if field not in json_doc:
            raise Exception('Field %s not found in doc %s.' % (field, file_path))
        json_doc[field] = value

    with open(file_path, 'w+') as json_file:
        json_file.write(json.dumps(json_doc, indent=2, sort_keys=True))

    return


def main():
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--file-path', required=True,
                        help='Path to json file.')
    parser.add_argument('--field', required=True,
                        help='Name of field to modify value for.')
    parser.add_argument('--value', required=True,
                        help='Value to set for the field.')
    args = parser.parse_args()
    modify_json_field_and_save(args.file_path, args.field, args.value)


if __name__ == '__main__':
    main()

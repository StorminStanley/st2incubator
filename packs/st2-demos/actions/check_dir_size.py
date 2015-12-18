#!/usr/bin/python

import argparse
import json
import re
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-D", "--directory",
                    help="Evaluate size of this directory",
                    dest="directory", required=True)
parser.add_argument("-t", "--threshold",
                    help="Maximum percentage of disk",
                    dest="threshold", required=True)
parser.add_argument("-a", "--action",
                    help="Run this script as an action",
                    action="store_true",
                    dest="action")
parser.add_argument("--debug",
                    help="Debug output",
                    action='store_true',
                    dest="debug")

args = parser.parse_args()

block_size = 1024
exitcode = 0

results = {}
results['args'] = vars(args)

df_output = subprocess.check_output(['df', '-B',
                                     str(block_size), args.directory])
df_table = df_output.split("\n")
headers = re.split("\s+", df_table[0])
del df_table[0]
results['df'] = {}
for result in df_table:
    result_parts = re.split('\s+', result)
    if len(result_parts) < 2:
        continue
    results['device'] = result_parts[0]
    disk_stats = dict(zip(headers, result_parts))
    results['df'][results['device']] = disk_stats

du_output = subprocess.check_output(['du', '-B',
                                     str(block_size), args.directory])
du_table = du_output.split("\n")
results['du'] = {}

for result in du_table:
    result_parts = re.split('\s+', result)
    if len(result_parts) < 2:
        continue
    size = result_parts[0]
    directory = result_parts[1]
    if directory != args.directory:
        continue
    results['du'][directory] = size

disk_size = float(results['df'][results['device']]['1K-blocks'])
dir_use = float(results['du'][args.directory])
results['usage'] = int(dir_use / disk_size * 100)

if int(results['usage']) >= int(args.threshold):
    results['status'] = 'ERROR'
    exitcode = 2
else:
    results['status'] = 'OK'

if args.action is True or args.debug is True:
    print(json.dumps(results))
else:
    print("%s is %s. Current Usage: %s" % (results['args']['directory'],
                                           results['status'],
                                           results['usage']) + '%')

sys.exit(exitcode)

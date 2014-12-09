#!/usr/bin/env python
import sys
import os
import subprocess

FILE=sys.argv[1]
REPOS=sys.argv[2].split(',')
REPOS[:] = ['apt/%s' % item for item in REPOS]

## Check to see if the file exists
if os.path.isfile(FILE):
    subprocess.call(['freight', 'add', FILE, ' '.join(REPOS)])
else:
    print "Requested file %s is not available" % FILE
    exit(1)
